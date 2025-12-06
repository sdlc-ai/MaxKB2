# coding=utf-8

from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter

from common.mixins.api_mixin import APIMixin
from common.result import ResultSerializer
from system_manage.serializers.email_setting import EmailSettingSerializer
from system_manage.serializers.user_resource_permission import UserResourcePermissionResponse, \
    UpdateUserResourcePermissionRequest


class EmailResponse(ResultSerializer):
    def get_data(self):
        return EmailSettingSerializer.Create()


class EmailSettingAPI(APIMixin):
    @staticmethod
    def get_request():
        return EmailSettingSerializer.Create()

    @staticmethod
    def get_response():
        return EmailResponse
