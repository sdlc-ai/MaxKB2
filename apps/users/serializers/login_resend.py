# coding=utf-8

from django.core.cache import cache
from django.utils.translation import gettext_lazy as _
from django.db.models import QuerySet

from common.exception.app_exception import AppApiException
from users.models.user import User
from users.serializers.user import send_email_code
from common.utils.email import mask_email
from common.constants.cache_version import Cache_Version


class ResendEmailCodeSerializer:
    """重发登录邮箱验证码序列化器"""
    
    @staticmethod
    def resend_email_code(instance):
        """
        重发登录邮箱验证码
        
        Args:
            instance: {"username": "superAdministrator"}
            
        Returns:
            {"masked_email": "y***n@capgemini.com", "cooldown_seconds": 60}
        """
        username = instance.get("username", "")
        if not username:
            raise AppApiException(1005, _("Username is required"))
        
        # 查询用户
        user = QuerySet(User).filter(username=username).first()
        if user is None:
            raise AppApiException(1005, _("User not found"))
        
        # 检查是否绑定邮箱
        if not user.email:
            raise AppApiException(1011, _("The user has not bound an email address. Please contact the administrator."))
        
        # 检查发送锁
        version, get_key = Cache_Version.SYSTEM.value
        lock_exists = cache.get(get_key(f"{user.email}:login_email_lock"), version=version)
        if lock_exists is not None:
            raise AppApiException(1010, _("Verification code sending too frequent, please try again later."))
        
        # 发送验证码（异步）
        try:
            from users.tasks.email import send_email_code_async
            send_email_code_async.delay(user.email, 'login_email', _('Login verification'), timeout=60 * 5)
        except AppApiException:
            raise
        except Exception as e:
            raise AppApiException(500, str(e))
        
        # 返回脱敏邮箱
        masked_email = mask_email(user.email)
        return {
            "masked_email": masked_email,
            "cooldown_seconds": 60
        }
