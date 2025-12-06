# coding=utf-8

from typing import List

from application.flow.compare import Compare


class IsNullCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'is_null':
            return True

    def compare(self, source_value, compare, target_value):
        try:
            return source_value is None or len(source_value) == 0
        except Exception as e:
            return False
