# coding=utf-8

from django.utils.translation import gettext_lazy as _
from drf_spectacular.utils import extend_schema
from rest_framework.request import Request
from rest_framework.views import APIView

from common import result
from system_manage.api.system import SystemProfileAPI
from system_manage.serializers.system import SystemProfileSerializer


class SystemProfile(APIView):
    @extend_schema(
        methods=['GET'],
        description=_('Get PorscheAi related information'),
        operation_id=_('Get PorscheAi related information'),  # type: ignore
        responses=SystemProfileAPI.get_response(),
        tags=[_('System parameters')]  # type: ignore
    )
    def get(self, request: Request):
        return result.success(SystemProfileSerializer.profile())
