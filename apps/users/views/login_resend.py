# coding=utf-8

import json
from django.utils.translation import gettext_lazy as _
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny

from common.handle.handle_exception import handle_exception
from common.result import result
from users.serializers.login_resend import ResendEmailCodeSerializer


@api_view(['POST'])
@permission_classes([AllowAny])
@handle_exception
def resend_email_code(request):
    """
    重发登录邮箱验证码接口
    
    POST /api/user/login/resend_email_code
    Body: {"username": "superAdministrator"}
    """
    request_data = request.data
    resend_data = ResendEmailCodeSerializer.resend_email_code(request_data)
    return result.success(resend_data)
