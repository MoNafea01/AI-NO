from .agents import Agent
from .retrieval_agent import RetrievalAgent
from .generation_agent import GenerationAgent

class StepsEstimateAgent(Agent):
    def __init__(self, logger, config):
        super().__init__("StepsEstimateAgent", logger)
        self.config = config
        self.retrieval_agent = RetrievalAgent(logger, config)
        self.generation_agent = GenerationAgent(logger, model_name=config['steps_estimate']['model'])

    async def execute(self, input_data):
        question = input_data["question"]

        # Load Context
        retrieval_result = await self.retrieval_agent.execute({
            "question": question,
            "mode": "3"  # mode '3' is for step estimation template
        })
        
        # Invoke model
        model_response = await self.generation_agent.execute({
            "question": question,
            "mode": "3",  # mode '3' is for step estimation docs
            "context": retrieval_result["context"]
        })
        self.logger.info(f"Estimated steps: {model_response['output']}")

        # Extract and return integer
        try:
            step_count = int(''.join(filter(str.isdigit, model_response['output'])))
            return step_count
        except Exception as e:
            self.logger.error(f"Failed to parse step count: {model_response} — {e}")
            return 1  # fallback to 1 step if extraction fails
