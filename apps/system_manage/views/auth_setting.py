# coding=utf-8

from drf_spectacular.utils import extend_schema
from rest_framework.request import Request
from rest_framework.views import APIView

from common.auth import TokenAuth
from common.auth.authentication import has_permissions
from common.constants.permission_constants import PermissionConstants, RoleConstants
from django.utils.translation import gettext_lazy as _
from common.result import result
from models_provider.api.model import DefaultModelResponse
from system_manage.api.auth_setting import AuthSettingAPI
from system_manage.serializers.auth_setting import AuthSettingSerializer


class AuthSettingView(APIView):
    authentication_classes = [TokenAuth]

    @extend_schema(methods=['PUT'],
                   summary=_('Create or update auth settings'),
                   description=_('Create or update auth settings'),
                   operation_id=_('Create or update auth settings'),  # type: ignore
                   request=AuthSettingAPI.get_request(),
                   responses=DefaultModelResponse.get_response(),
                   tags=[_('Auth Settings')])  # type: ignore
    @has_permissions(PermissionConstants.LOGIN_AUTH_EDIT, RoleConstants.ADMIN)
    def put(self, request: Request):
        return result.success(
            AuthSettingSerializer.Create(
                data=request.data).update_or_save())

    @extend_schema(methods=['GET'],
                   summary=_('Get auth settings'),
                   description=_('Get auth settings'),
                   operation_id=_('Get auth settings'),  # type: ignore
                   responses=DefaultModelResponse.get_response(),
                   tags=[_('Auth Settings')])  # type: ignore
    @has_permissions(PermissionConstants.LOGIN_AUTH_READ, RoleConstants.ADMIN)
    def get(self, request: Request):
        return result.success(
            AuthSettingSerializer.one())
