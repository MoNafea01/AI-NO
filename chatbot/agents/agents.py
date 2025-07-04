from abc import ABC, abstractmethod
from langchain_huggingface import HuggingFaceEmbeddings
from core.utils import load_config
config = load_config('config/config.yaml')

retriever_class = HuggingFaceEmbeddings(model_name=config['retrieval']['embedding_model'])


class Agent(ABC):
    def __init__(self, name, logger):
        self.name = name
        self.logger = logger

    @abstractmethod
    async def execute(self, input_data, context=None):
        pass
