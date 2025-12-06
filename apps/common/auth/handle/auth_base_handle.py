# coding=utf-8

from abc import ABC, abstractmethod


class AuthBaseHandle(ABC):
    @abstractmethod
    def support(self, request, token: str, get_token_details):
        pass

    @abstractmethod
    def handle(self, request, token: str, get_token_details):
        pass
