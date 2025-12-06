# coding=utf-8

from common.chunk.impl.mark_chunk_handle import MarkChunkHandle

handles = [MarkChunkHandle()]


def text_to_chunk(text: str, chunk_size: int = 256):
    chunk_list = [text]
    for handle in handles:
        chunk_list = handle.handle(chunk_list, chunk_size)
    return chunk_list
