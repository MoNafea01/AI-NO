from .agents import Agent
from .retrieval_agent import RetrievalAgent
from .generation_agent import GenerationAgent

# ModeSelectorAgent for selecting the mode of operation based on user queries
# It retrieves relevant documents and classifies the query into a specific mode (e.g., manual, auto, etc.)
class ModeSelectorAgent(Agent):
    def __init__(self, logger, config):
        super().__init__("ModeSelectorAgent", logger)
        self.config = config
        self.retrieval_agent = RetrievalAgent(logger, config)
        self.generation_agent = GenerationAgent(logger, model_name=config['mode_selector']['model'])

    async def execute(self, input_data, context=None):
        query = input_data["question"]

        
        node_result = await self.retrieval_agent.execute({
            "question": query,
            "mode": 'auto_mode_nodes'
        })
        auto_result = await self.retrieval_agent.execute({
            "question": query,
            "mode": 'selector'
        })
        
        self.logger.debug(f"Retrieved {len(node_result['docs'])} documents from auto node docs, {len(auto_result['docs'])} from auto docs")

        classification = await self.generation_agent.execute({
            "question": query,
            "mode": 'selector',
            "context": auto_result['context'],
            "nodes": node_result['context']
        })
        classification = classification['output'].strip().lower()
        self.logger.debug(f"Query classified as: {classification}")

        return {"mode": classification}
