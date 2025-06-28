from .agents import Agent
from .retrieval_agent import RetrievalAgent
from .generation_agent import GenerationAgent

# RouterAgent for routing user queries to the appropriate agent based on classification
# It uses a retrieval agent to fetch relevant documents and a generation agent to classify the query.
class RouterAgent(Agent):
    def __init__(self, logger, config):
        super().__init__("RouterAgent", logger)
        self.config = config
        self.retrieval_agent = RetrievalAgent(logger, config)
        self.generation_agent = GenerationAgent(logger, model_name=config['router']['model'])

    async def execute(self, input_data, context=None):
        query = input_data["question"]
        
        retrieval_result = await self.retrieval_agent.execute({
            "question": query,
            "mode": "router"
        })
        self.logger.debug(f"Retrieved {len(retrieval_result['docs'])} documents")
        
        self.logger.info(f"Classifying query: {query}")
        try:
            classification = await self.generation_agent.execute({
                "question": query,
                "mode": "router",
                "context": retrieval_result['context']
            })
            
            classification = classification['output'].strip().lower()
            self.logger.debug(f"Query classified as: {classification}")
            
            if classification not in ["agent", "chat"]:
                self.logger.warning(f"Unexpected classification: {classification}. Defaulting to 'chat'.")
                classification = "chat"

            return {"route": classification}
        except Exception as e:
            self.logger.error(f"Error in RouterAgent: {str(e)}")
            raise
