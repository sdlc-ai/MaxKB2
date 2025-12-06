# coding=utf-8

from abc import ABC, abstractmethod


class IBaseModelHandle(ABC):
    @abstractmethod
    def get_model_dict(self):
        pass
