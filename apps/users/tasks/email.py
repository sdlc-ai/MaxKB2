# coding=utf-8

from django.utils.translation import gettext_lazy as _

from common.exception.app_exception import AppApiException
from ops import celery_app


@celery_app.task(name='celery:send_email_code_async')
def send_email_code_async(email: str, code_type: str, state_label: str = '', timeout: int = 60 * 30):
    """
    异步发送邮箱验证码任务
    
    :param email: 接收邮箱
    :param code_type: 验证码类型
    :param state_label: 邮件标题中的动作描述
    :param timeout: 验证码缓存超时时间（秒）
    """
    from users.serializers.user import send_email_code
    try:
        return send_email_code(email, code_type, state_label, timeout)
    except AppApiException:
        raise
    except Exception as e:
        raise AppApiException(500, _("Email sending failed: {error}").format(error=str(e)))
