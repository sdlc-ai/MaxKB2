from typing import Dict

from langchain_openai import OpenAIEmbeddings

from models_provider.base_model_provider import PorscheAIBaseModel


class VolcanicEngineEmbeddingModel(PorscheAIBaseModel, OpenAIEmbeddings):
    @staticmethod
    def new_instance(model_type, model_name, model_credential: Dict[str, object], **model_kwargs):
        return VolcanicEngineEmbeddingModel(
            openai_api_key=model_credential.get('api_key'),
            model=model_name,
            openai_api_base=model_credential.get('api_base'),
            check_embedding_ctx_length=False,
        )
