# coding=utf-8
"""
    @project: maxkb
    @Author：虎
    @file： md_parse_qa_handle.py
    @date：2024/5/21 14:59
    @desc:
"""
import re
import traceback

from charset_normalizer import detect

from common.handle.base_parse_qa_handle import BaseParseQAHandle, get_title_row_index_dict, get_row_value
from common.utils.logger import maxkb_logger


class MarkdownParseQAHandle(BaseParseQAHandle):
    def support(self, file, get_buffer):
        file_name: str = file.name.lower()
        if file_name.endswith(".md") or file_name.endswith(".markdown"):
            return True
        return False

    def parse_markdown_table(self, content):
        """解析 Markdown 表格,返回表格数据列表"""
        tables = []
        lines = content.split('\n')
        i = 0

        while i < len(lines):
            line = lines[i].strip()
            # 检测表格开始(包含 | 符号)
            if '|' in line and line.startswith('|'):
                table_data = []
                # 读取表头
                header = [cell.strip() for cell in line.split('|')[1:-1]]
                table_data.append(header)
                i += 1

                # 跳过分隔行 (例如: | --- | --- |)
                if i < len(lines) and re.match(r'\s*\|[\s\-:]+\|\s*', lines[i]):
                    i += 1

                # 读取数据行
                while i < len(lines):
                    line = lines[i].strip()
                    if not line.startswith('|'):
                        break
                    row = [cell.strip() for cell in line.split('|')[1:-1]]
                    if len(row) > 0:
                        table_data.append(row)
                    i += 1

                if len(table_data) > 1:  # 至少有表头和一行数据
                    tables.append(table_data)
            else:
                i += 1

        return tables

    def handle(self, file, get_buffer, save_image):
        buffer = get_buffer(file)
        try:
            # 检测编码并读取文件内容
            encoding = detect(buffer)['encoding']
            content = buffer.decode(encoding if encoding else 'utf-8')

            # 解析 Markdown 表格
            tables = self.parse_markdown_table(content)

            if not tables:
                return [{'name': file.name, 'paragraphs': []}]

            paragraph_list = []

            # 处理每个表格
            for table in tables:
                if len(table) < 2:
                    continue

                title_row_list = table[0]
                title_row_index_dict = get_title_row_index_dict(title_row_list)

                # 处理表格的每一行数据
                for row in table[1:]:
                    content = get_row_value(row, title_row_index_dict, 'content')
                    if content is None:
                        continue

                    problem = get_row_value(row, title_row_index_dict, 'problem_list')
                    problem = str(problem) if problem is not None else ''
                    problem_list = [{'content': p[0:255]} for p in problem.split('\n') if len(p.strip()) > 0]

                    title = get_row_value(row, title_row_index_dict, 'title')
                    title = str(title) if title is not None else ''

                    paragraph_list.append({
                        'title': title[0:255],
                        'content': content[0:102400],
                        'problem_list': problem_list
                    })

            return [{'name': file.name, 'paragraphs': paragraph_list}]

        except Exception as e:
            maxkb_logger.error(f"Error processing Markdown file {file.name}: {e}, {traceback.format_exc()}")
            return [{'name': file.name, 'paragraphs': []}]
