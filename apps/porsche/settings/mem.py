# coding=utf-8
import os
import gc
import threading
from porsche.const import CONFIG
from common.utils.logger import porsche_logger
import random

CURRENT_PID=os.getpid()
# 1 hour
GC_INTERVAL = 3600

def enable_force_gc():
    collected = gc.collect()
    porsche_logger.debug(f"(PID: {CURRENT_PID}) Forced GC ({collected} objects collected)")
    t = threading.Timer(GC_INTERVAL - random.randint(0, 900), enable_force_gc)
    t.daemon = True
    t.start()

if CONFIG.get("ENABLE_FORCE_GC", '1') == "1":
    porsche_logger.info(f"(PID: {CURRENT_PID}) Forced GC enabled")
    enable_force_gc()
