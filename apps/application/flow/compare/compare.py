# coding=utf-8

from abc import abstractmethod
from typing import List


class Compare:
    @abstractmethod
    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        pass

    @abstractmethod
    def compare(self, source_value, compare, target_value):
        pass
