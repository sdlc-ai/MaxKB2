# coding=utf-8

from typing import Dict

from langchain_community.embeddings import OpenAIEmbeddings

from models_provider.base_model_provider import PorscheAIBaseModel


class VllmEmbeddingModel(PorscheAIBaseModel, OpenAIEmbeddings):
    @staticmethod
    def new_instance(model_type, model_name, model_credential: Dict[str, object], **model_kwargs):
        return VllmEmbeddingModel(
            model=model_name,
            openai_api_key=model_credential.get('api_key'),
            openai_api_base=model_credential.get('api_base'),
        )
