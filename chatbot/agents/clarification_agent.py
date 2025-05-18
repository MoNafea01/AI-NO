from .agents import Agent
from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from chatbot.core.rag_pipeline import get_llm
from chatbot.core.utils import load_json_file
import re

class ClarificationAgent(Agent):
    def __init__(self, logger, config):
        super().__init__("ClarificationAgent", logger)
        self.config = config
        self.model = get_llm(config['clarification']['model'])
        self.prompt = ChatPromptTemplate.from_template(config['clarification']['prompt_template'])
        self.chain = (
            self.prompt 
            | self.model 
            | StrOutputParser()
            )
        self.node_params = load_json_file(config['clarification']['data_mapping'])

    async def execute(self, input_data, context=None):
        query = input_data["query"]
        self.logger.info(f"Checking query for completeness: {query}")
        try:
            # Extract node type from query (e.g., "neural net" -> neural_network)
            node_type = self._extract_node_type(query)
            required_params = self._get_required_params(node_type)
            
            # Check if required parameters are present
            missing_params = self._check_missing_params(query, required_params)
            
            if not missing_params:
                self.logger.debug("Query is complete")
                return {"status": "complete", "query": query}
            
            # Generate clarification prompt
            clarification = await self.chain.ainvoke({
                "query": query,
                "node_type": node_type,
                "missing_params": ", ".join(missing_params),
                "suggested_params": self._get_suggested_params(node_type, missing_params)
            })
            self.logger.debug(f"Clarification needed: {clarification}")
            return {"status": "needs_clarification", "prompt": clarification}
        except Exception as e:
            self.logger.error(f"Error in ClarificationAgent: {str(e)}")
            raise

    def _extract_node_type(self, query):
        # Simple heuristic: map query keywords to node types
        query = query.lower()
        if "neural net" in query or "neural network" in query:
            return "neural_network"
        elif "knn" in query:
            return "knn_classifier"
        elif "logistic regression" in query:
            return "logistic_regression"
        else:
            return "unknown"

    def _get_required_params(self, node_type):
        params = self.node_params.get(node_type, {})
        # Extract top-level parameters and nested params
        required = list(params.keys())
        if "params" in params:
            required.extend(params["params"].keys())
        return required
    
    def _check_missing_params(self, query, required_params):
        missing = []
        query = query.lower()
        for param in required_params:
            if not re.search(rf"\b{param}\b", query, re.IGNORECASE):
                missing.append(param)
        return missing

    def _get_suggested_params(self, node_type, missing_params):
        suggestions = []
        params = self.node_params.get(node_type, {})
        # Handle top-level and nested params
        for param in missing_params:
            if param in params:
                default = params[param]
            elif "params" in params and param in params["params"]:
                default = params["params"][param]
            else:
                default = "unspecified"
            suggestions.append(f"{param} (e.g., {default})")
        return "; ".join(suggestions)