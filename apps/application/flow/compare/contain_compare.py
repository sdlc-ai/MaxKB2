# coding=utf-8

from typing import List

from application.flow.compare.compare import Compare


class ContainCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'contain':
            return True

    def compare(self, source_value, compare, target_value):
        if isinstance(source_value, str):
            return str(target_value) in source_value
        elif isinstance(source_value, list):
            return any([str(item) == str(target_value) for item in source_value])
        else:
            return str(target_value) in str(source_value)
