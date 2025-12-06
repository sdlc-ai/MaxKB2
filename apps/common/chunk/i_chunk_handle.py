# coding=utf-8

from abc import ABC, abstractmethod
from typing import List


class IChunkHandle(ABC):
    @abstractmethod
    def handle(self, chunk_list: List[str], chunk_size: int = 256):
        pass
