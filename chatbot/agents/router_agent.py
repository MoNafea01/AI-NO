from .agents import Agent
from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from chatbot.core.rag_pipeline import get_llm
from chatbot.core.docs import get_docs

class RouterAgent(Agent):
    def __init__(self, logger, config):
        super().__init__("RouterAgent", logger)
        self.config = config
        self.model = get_llm(config['router']['model'])
        self.prompt = ChatPromptTemplate.from_template(config['router']['prompt_template'])
        self.chain = self.prompt | self.model | StrOutputParser()

    async def execute(self, input_data, context=None):
        query = input_data["question"]
        docs_context = get_docs('1')
        self.logger.info(f"Classifying query: {query}")
        try:
            classification = await self.chain.ainvoke({"query": query, "context": docs_context})
            classification = classification.strip().lower()
            self.logger.debug(f"Query classified as: {classification}")
            
            if classification == "cli":
                return {"route": "cli", "query": query}
            elif classification == "chat":
                return {"route": "chat", "query": query}
            else:
                self.logger.warning(f"Invalid classification: {classification}")
                return {"route": "chat", "query": query}  # Default to chat
        except Exception as e:
            self.logger.error(f"Error in RouterAgent: {str(e)}")
            raise