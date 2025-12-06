# coding=utf-8

from typing import List

from application.flow.compare import Compare


class NotContainCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'not_contain':
            return True

    def compare(self, source_value, compare, target_value):
        if isinstance(source_value, str):
            return str(target_value) not in source_value
        elif isinstance(self, list):
            return not any([str(item) == str(target_value) for item in source_value])
        else:
            return str(target_value) not in str(source_value)
