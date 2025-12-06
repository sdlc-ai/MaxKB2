# coding=utf-8

from common.mixins.api_mixin import APIMixin
from common.result import ResultSerializer
from system_manage.serializers.system import SystemProfileResponseSerializer


class SystemProfileResult(ResultSerializer):
    def get_data(self):
        return SystemProfileResponseSerializer()


class SystemProfileAPI(APIMixin):
    @staticmethod
    def get_response():
        return SystemProfileResult
