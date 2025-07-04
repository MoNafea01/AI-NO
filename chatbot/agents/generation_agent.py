from .agents import Agent
import os
from chatbot.core.rag_pipeline import get_llm
from chatbot.core.templates import get_template
from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# GenerationAgent for generating CLI commands based on user queries
# It uses a language model to generate commands based on the provided context and question.
class GenerationAgent(Agent):
    def __init__(self, logger, model_name="gemini-2.0-flash"):
        super().__init__("GenerationAgent", logger)
        self.model = model_name
        self.output_parser = StrOutputParser()

    async def execute(self, input_data, context=None):
        google_keys = [os.getenv("GOOGLE_API_KEY"), os.getenv("GOOGLE_API_KEY2")]
        if isinstance(self.model, str):
            for i, google_key in enumerate(google_keys):
                try:
                    self.model = get_llm(
                        model_name=self.model,
                        temperature=0.1,
                        max_tokens=500,
                        google_key=google_key
                    )
                    return await self.generate_response(input_data)
                except Exception as e:
                    self.logger.error(f"Failed to initialize LLM for keys[{i}]: {str(e)}")
            raise
        else:
            self.logger.info(f"Using existing model instance: {self.model}")
            return await self.generate_response(input_data)
        
        
    async def generate_response(self, input_data):
        question = input_data["question"]
        mode = input_data["mode"]
        cur_iter = input_data.get("cur_iter", 0)
        nodes_context = input_data.get("nodes", "")
        docs_context = input_data["context"]
        
        template = get_template(mode)
        
        prompt = ChatPromptTemplate.from_template(template)
        chain = (
            prompt 
            | self.model 
            | self.output_parser
            )
        
        result = chain.invoke({"question": question, "context": docs_context, "cur_iter": cur_iter, "nodes": nodes_context})
        self.logger.info(f"Generated CLI command: {result}")
        return {"output": result}
