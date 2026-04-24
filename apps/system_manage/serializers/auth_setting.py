# coding=utf-8

from django.db.models import QuerySet
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from system_manage.models import SystemSetting, SettingType


class AuthSettingSerializer(serializers.Serializer):
    @staticmethod
    def one():
        system_setting = QuerySet(SystemSetting).filter(type=SettingType.AUTH.value).first()
        if system_setting is None:
            return {
                'default_value': 'LOCAL',
                'max_attempts': 1,
                'login_email_verification_enabled': False,
                'login_email_verification_scope': 'ALL',
                'auth_types': [{'label': _('Local Login'), 'value': 'LOCAL'}]
            }
        meta = system_setting.meta or {}
        return {
            'default_value': meta.get('default_value', 'LOCAL'),
            'max_attempts': meta.get('max_attempts', 1),
            'login_email_verification_enabled': meta.get('login_email_verification_enabled', False),
            'login_email_verification_scope': meta.get('login_email_verification_scope', 'ALL'),
            'auth_types': [{'label': _('Local Login'), 'value': 'LOCAL'}]
        }

    class Create(serializers.Serializer):
        default_value = serializers.CharField(required=False, default='LOCAL', label=_('Default login method'))
        max_attempts = serializers.IntegerField(required=False, default=1, min_value=-1, max_value=10,
                                                label=_('Display captcha threshold'))
        login_email_verification_enabled = serializers.BooleanField(required=False, default=False,
                                                                    label=_('Login email verification'))
        login_email_verification_scope = serializers.ChoiceField(required=False, choices=['ALL', 'ADMIN'],
                                                                  default='ALL',
                                                                  label=_('Login email verification scope'))

        def update_or_save(self):
            self.is_valid(raise_exception=True)
            system_setting = QuerySet(SystemSetting).filter(type=SettingType.AUTH.value).first()
            if system_setting is None:
                system_setting = SystemSetting(type=SettingType.AUTH.value)
            system_setting.meta = self.validated_data
            system_setting.save()
            result = self.validated_data.copy()
            result['auth_types'] = [{'label': _('Local Login'), 'value': 'LOCAL'}]
            return result
