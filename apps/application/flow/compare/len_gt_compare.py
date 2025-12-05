# coding=utf-8

from typing import List

from application.flow.compare import Compare


class LenGTCompare(Compare):

    def support(self, node_id, fields: List[str], source_value, compare, target_value):
        if compare == 'len_gt':
            return True

    def compare(self, source_value, compare, target_value):
        try:
            return len(source_value) > int(target_value)
        except Exception as e:
            return False
