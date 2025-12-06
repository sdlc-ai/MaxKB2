# coding=utf-8

from typing import List

from application.flow.compare import Compare


class IsNotNullCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'is_not_null':
            return True

    def compare(self, source_value, compare, target_value):
        return source_value is not None and len(source_value) > 0
