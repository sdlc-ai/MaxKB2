# coding=utf-8

from .clean_chat_job import *
from .clean_debug_file_job import *
from .client_access_num_job import *


def run():
    # client_access_num_job.run()
    clean_chat_job.run()
    clean_debug_file_job.run()
    client_access_num_job.run()
