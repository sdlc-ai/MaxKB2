# coding=utf-8

from typing import List

from application.flow.compare import Compare


class GTCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'gt':
            return True

    def compare(self, source_value, compare, target_value):
        try:
            return float(source_value) > float(target_value)
        except Exception as e:
            try:
                return str(source_value) > str(target_value)
            except Exception as _:
                pass
            return False
