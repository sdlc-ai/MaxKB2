# coding=utf-8

from django.core.cache import cache
from django.utils.translation import gettext_lazy as _
from drf_spectacular.utils import extend_schema
from rest_framework.request import Request
from rest_framework.views import APIView

from common import result
from common.auth import TokenAuth
from common.constants.cache_version import Cache_Version
from common.log.log import log
from common.utils.common import encryption
from models_provider.api.model import DefaultModelResponse
from users.api.login import LoginAPI, CaptchaAPI
from users.serializers.login import LoginSerializer, CaptchaSerializer

# 导入系统设置缓存版本，用于清理邮箱验证码
system_version, system_get_key = Cache_Version.SYSTEM.value


def _get_details(request):
    path = request.path
    body = request.data
    query = request.query_params
    return {
        'path': path,
        'body': {**body, 'password': encryption(body.get('password', ''))},
        'query': query
    }


class LoginView(APIView):
    @extend_schema(methods=['POST'],
                   description=_("Log in"),
                   summary=_("Log in"),
                   operation_id=_("Log in"),  # type: ignore
                   tags=[_("User Management")],  # type: ignore
                   request=LoginAPI.get_request(),
                   responses=LoginAPI.get_response())
    @log(menu='User management', operate='Log in', get_user=lambda r: {'username': r.data.get('username', None)},
         get_details=_get_details,
         get_operation_object=lambda r, k: {'name': r.data.get('username')})
    def post(self, request: Request):
        return result.success(LoginSerializer().login(request.data))


class Logout(APIView):
    authentication_classes = [TokenAuth]

    @extend_schema(methods=['POST'],
                   summary=_("Sign out"),
                   description=_("Sign out"),
                   operation_id=_("Sign out"),  # type: ignore
                   tags=[_("User Management")],  # type: ignore
                   responses=DefaultModelResponse.get_response())
    @log(menu='User management', operate='Sign out',
         get_operation_object=lambda r, k: {'name': r.user.username})
    def post(self, request: Request):
        version, get_key = Cache_Version.TOKEN.value
        token = request.META.get('HTTP_AUTHORIZATION')[7:]
        cache.delete(get_key(token=token), version=version)
        
        # 清理该用户的邮箱验证码缓存，防止退出后验证码仍有效
        user = request.user
        if user and user.email:
            email_code_key = system_get_key(f"{user.email}:login_email")
            email_lock_key = system_get_key(f"{user.email}:login_email_lock")
            email_attempts_key = system_get_key(f"{user.email}:login_email_attempts")
            temp_token_key = system_get_key(f"{user.email}:login_temp_token")
            cache.delete(email_code_key, version=system_version)
            cache.delete(email_lock_key, version=system_version)
            cache.delete(email_attempts_key, version=system_version)
            cache.delete(temp_token_key, version=system_version)
            
        return result.success(True)


class CaptchaView(APIView):
    @extend_schema(methods=['GET'],
                   summary=_("Get captcha"),
                   description=_("Get captcha"),
                   operation_id=_("Get captcha"),  # type: ignore
                   tags=[_("User Management")],  # type: ignore
                   responses=CaptchaAPI.get_response())
    def get(self, request: Request):
        username = request.query_params.get('username', None)
        return result.success(CaptchaSerializer().generate(username))
