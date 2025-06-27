from .agents import Agent
from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from chatbot.core.rag_pipeline import get_llm
from chatbot.core.templates import get_template

class GenerationAgent(Agent):
    def __init__(self, logger, model_name="gemini-2.0-flash"):
        super().__init__("GenerationAgent", logger)
        self.model = get_llm(model_name)
        self.output_parser = StrOutputParser()

    async def execute(self, input_data, context=None):
        question = input_data["question"]
        mode = input_data["mode"]
        cur_iter = input_data.get("cur_iter", 0)
        nodes_context = input_data.get("nodes", "")
        docs_context = input_data["context"]

        # Dynamic prompt construction
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
