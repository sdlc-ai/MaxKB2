# coding=utf-8

from abc import ABC, abstractmethod


class BaseParseTableHandle(ABC):
    @abstractmethod
    def support(self, file, get_buffer):
        pass

    @abstractmethod
    def handle(self, file, get_buffer,save_image):
        pass

    @abstractmethod
    def get_content(self, file, save_image):
        pass