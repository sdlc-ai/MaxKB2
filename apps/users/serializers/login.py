# coding=utf-8

import base64
import datetime
import json

from captcha.image import ImageCaptcha
from django.core import signing
from django.core.cache import cache
from django.db.models import QuerySet
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from application.models import ApplicationAccessToken
from common.constants.authentication_type import AuthenticationType
from common.constants.cache_version import Cache_Version
from common.constants.permission_constants import RoleConstants
from common.database_model_manage.database_model_manage import DatabaseModelManage
from common.exception.app_exception import AppApiException
from common.utils.common import password_encrypt, get_random_chars
from common.utils.rsa_util import encrypt, decrypt
from porsche.const import CONFIG
from users.models import User


class LoginRequest(serializers.Serializer):
    username = serializers.CharField(required=True, max_length=64, help_text=_("Username"), label=_("Username"))
    password = serializers.CharField(required=True, max_length=128, label=_("Password"))
    captcha = serializers.CharField(required=False, max_length=64, label=_('captcha'), allow_null=True,
                                    allow_blank=True)
    encryptedData = serializers.CharField(required=False, label=_('encryptedData'), allow_null=True,
                                          allow_blank=True)
    email_code = serializers.CharField(required=False, max_length=6, label=_('Email verification code'),
                                       allow_null=True, allow_blank=True)


system_version, system_get_key = Cache_Version.SYSTEM.value


class LoginResponse(serializers.Serializer):
    """
    登录响应对象
    """
    token = serializers.CharField(required=True, label=_("token"))


def record_login_fail(username: str, expire: int = 600):
    """记录登录失败次数"""
    if not username:
        return
    fail_key = system_get_key(f'system_{username}')
    fail_count = cache.get(fail_key, version=system_version)
    if fail_count is None:
        cache.set(fail_key, 1, timeout=expire, version=system_version)
    else:
        cache.incr(fail_key, 1, version=system_version)


class LoginSerializer(serializers.Serializer):

    @staticmethod
    def get_auth_setting():
        """获取认证设置"""
        auth_setting_model = DatabaseModelManage.get_model('auth_setting')
        auth_setting = {}
        if auth_setting_model:
            setting_obj = auth_setting_model.objects.filter(param_key='auth_setting').first()
            if setting_obj:
                try:
                    auth_setting = json.loads(setting_obj.param_value) or {}
                except Exception:
                    auth_setting = {}
        else:
            # 开源版：从 SystemSetting 读取
            try:
                from system_manage.models import SystemSetting, SettingType
                from django.db.models import QuerySet
                system_setting = QuerySet(SystemSetting).filter(type=SettingType.AUTH.value).first()
                if system_setting and system_setting.meta:
                    auth_setting = system_setting.meta
            except Exception:
                auth_setting = {}
        return auth_setting

    @staticmethod
    def _need_email_verification(user, auth_setting):
        """判断该用户是否需要邮箱验证码"""
        if not auth_setting.get('login_email_verification_enabled', False):
            return False
        scope = auth_setting.get('login_email_verification_scope', 'ALL')
        if scope == 'ALL':
            return True
        if scope == 'ADMIN' and user.role == RoleConstants.ADMIN.name:
            return True
        return False

    @staticmethod
    def login(instance):
        username = instance.get("username", "")
        encryptedData = instance.get("encryptedData", "")
        if encryptedData:
            json_data = json.loads(decrypt(encryptedData))
            instance.update(json_data)
        try:
            LoginRequest(data=instance).is_valid(raise_exception=True)
        except Exception as e:
            record_login_fail(username)
            raise e
        auth_setting = LoginSerializer.get_auth_setting()

        max_attempts = auth_setting.get("max_attempts", 1)
        password = instance.get("password")
        captcha = instance.get("captcha", "")
        email_code = instance.get("email_code", "")

        # 判断是否需要验证码
        need_captcha = False
        if max_attempts == -1:
            need_captcha = False
        elif max_attempts > 0:
            fail_count = cache.get(system_get_key(f'system_{username}'), version=system_version) or 0
            need_captcha = fail_count >= max_attempts

        if need_captcha:
            if not captcha:
                raise AppApiException(1005, _("Captcha is required"))

            captcha_cache = cache.get(
                Cache_Version.CAPTCHA.get_key(captcha=f"system_{username}"),
                version=Cache_Version.CAPTCHA.get_version()
            )
            if captcha_cache is None or captcha.lower() != captcha_cache:
                raise AppApiException(1005, _("Captcha code error or expiration"))

        user = QuerySet(User).filter(username=username, password=password_encrypt(password)).first()
        if user is None:
            record_login_fail(username)
            raise AppApiException(500, _('The username or password is incorrect'))
        if not user.is_active:
            record_login_fail(username)
            raise AppApiException(1005, _("The user has been disabled, please contact the administrator!"))

        # 判断是否需要邮箱验证码
        if LoginSerializer._need_email_verification(user, auth_setting):
            version, get_key = Cache_Version.SYSTEM.value
            if not email_code:
                # 阶段一：未提供邮箱验证码
                if not user.email:
                    raise AppApiException(500, _("The user has not bound an email address. Please contact the administrator."))
                # 检查是否已有发送锁,避免重复发送
                lock_exists = cache.get(get_key(f"{user.email}:login_email_lock"), version=version)
                if lock_exists is not None:
                    raise AppApiException(1009, _("Verification code has been sent. Please check your email."))
                try:
                    from users.serializers.user import send_email_code
                    send_email_code(user.email, 'login_email', _('Login verification'), timeout=60 * 5)
                except AppApiException:
                    raise
                except Exception as e:
                    raise AppApiException(500, str(e))
                raise AppApiException(1009, _("Verification code has been sent to your email. Please enter the code to complete login."))
            else:
                # 阶段二：校验邮箱验证码
                cache_code = cache.get(get_key(f"{user.email}:login_email"), version=version)
                if cache_code is None or cache_code != email_code:
                    record_login_fail(username)
                    raise AppApiException(1005, _("Email verification code error or expiration"))
                # 校验通过，清除验证码缓存
                cache.delete(get_key(f"{user.email}:login_email"), version=version)

        cache.delete(system_get_key(f'system_{username}'), version=system_version)
        token = signing.dumps({'username': user.username,
                               'id': str(user.id),
                               'email': user.email,
                               'type': AuthenticationType.SYSTEM_USER.value})
        version, get_key = Cache_Version.TOKEN.value
        timeout = CONFIG.get_session_timeout()
        cache.set(get_key(token), user, timeout=timeout, version=version)
        return {'token': token}


class CaptchaResponse(serializers.Serializer):
    """
       登录响应对象
       """
    captcha = serializers.CharField(required=True, label=_("captcha"))


class CaptchaSerializer(serializers.Serializer):
    @staticmethod
    def generate(username: str, type: str = 'system'):
        auth_setting = LoginSerializer.get_auth_setting()
        max_attempts = auth_setting.get("max_attempts", 1)

        need_captcha = True
        if max_attempts == -1:
            need_captcha = False
        elif max_attempts > 0:
            fail_count = cache.get(system_get_key(f'system_{username}'), version=system_version) or 0
            need_captcha = fail_count >= max_attempts

        return CaptchaSerializer._generate_captcha_if_needed(username, type, need_captcha)

    @staticmethod
    def chat_generate(username: str, type: str = 'chat', access_token: str = ''):
        application_access_token = ApplicationAccessToken.objects.filter(
            access_token=access_token
        ).first()

        if not application_access_token:
            raise AppApiException(1005, _('Invalid access token'))

        auth_setting = application_access_token.authentication_value
        max_attempts = auth_setting.get("max_attempts", 1)

        need_captcha = True
        if max_attempts == -1:
            need_captcha = False
        elif max_attempts > 0:
            fail_count = cache.get(system_get_key(f'{type}_{username}'), version=system_version) or 0
            need_captcha = fail_count >= max_attempts


        return CaptchaSerializer._generate_captcha_if_needed(username, type, need_captcha)

    @staticmethod
    def _generate_captcha_if_needed(username: str, type: str, need_captcha: bool):
        """
        提取的公共验证码生成方法
        """
        if need_captcha:
            chars = get_random_chars()
            image = ImageCaptcha()
            data = image.generate(chars)
            captcha = base64.b64encode(data.getbuffer())
            cache.set(Cache_Version.CAPTCHA.get_key(captcha=f'{type}_{username}'), chars.lower(),
                      timeout=300, version=Cache_Version.CAPTCHA.get_version())
            return {'captcha': 'data:image/png;base64,' + captcha.decode()}
        return {'captcha': ''}
        """
        if need_captcha:
            chars = get_random_chars()
            image = ImageCaptcha()
            data = image.generate(chars)
            captcha = base64.b64encode(data.getbuffer())
            cache.set(Cache_Version.CAPTCHA.get_key(captcha=f'{type}_{username}'), chars.lower(),
                      timeout=300, version=Cache_Version.CAPTCHA.get_version())
            return {'captcha': 'data:image/png;base64,' + captcha.decode()}
        return {'captcha': ''}
        """
        if need_captcha:
            chars = get_random_chars()
            image = ImageCaptcha()
            data = image.generate(chars)
            captcha = base64.b64encode(data.getbuffer())
            cache.set(Cache_Version.CAPTCHA.get_key(captcha=f'{type}_{username}'), chars.lower(),
                      timeout=300, version=Cache_Version.CAPTCHA.get_version())
            return {'captcha': 'data:image/png;base64,' + captcha.decode()}
        return {'captcha': ''}
