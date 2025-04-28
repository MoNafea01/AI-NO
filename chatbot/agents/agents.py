from abc import ABC, abstractmethod
import logging

class Agent(ABC):
    def __init__(self, name, logger):
        self.name = name
        self.logger = logger

    @abstractmethod
    async def execute(self, input_data, context=None):
        pass
