# coding=utf-8

from typing import List

from application.flow.compare import Compare


class IsTrueCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'is_true':
            return True

    def compare(self, source_value, compare, target_value):
        try:
            return source_value is True
        except Exception as e:
            return False
