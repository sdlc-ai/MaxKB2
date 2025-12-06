# coding=utf-8

from common.database_model_manage.handle.base_handle import IBaseModelHandle


class DefaultBaseModelHandle(IBaseModelHandle):
    def get_model_dict(self):
        return {}
