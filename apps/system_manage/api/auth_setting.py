# coding=utf-8

from common.mixins.api_mixin import APIMixin
from common.result import ResultSerializer
from system_manage.serializers.auth_setting import AuthSettingSerializer


class AuthSettingResponse(ResultSerializer):
    def get_data(self):
        return AuthSettingSerializer.Create()


class AuthSettingAPI(APIMixin):
    @staticmethod
    def get_request():
        return AuthSettingSerializer.Create()

    @staticmethod
    def get_response():
        return AuthSettingResponse
