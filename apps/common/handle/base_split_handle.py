# coding=utf-8

from abc import ABC, abstractmethod
from typing import List


class BaseSplitHandle(ABC):
    @abstractmethod
    def support(self, file, get_buffer):
        pass

    @abstractmethod
    def handle(self, file, pattern_list: List, with_filter: bool, limit: int, get_buffer, save_image):
        pass

    @abstractmethod
    def get_content(self, file, save_image):
        pass
