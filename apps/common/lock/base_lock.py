# coding=utf-8

from abc import ABC, abstractmethod


class BaseLock(ABC):
    @abstractmethod
    def try_lock(self, key, timeout):
        pass

    @abstractmethod
    def un_lock(self, key):
        pass
