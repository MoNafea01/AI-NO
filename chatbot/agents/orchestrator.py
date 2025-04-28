from .agents import Agent
from .retrieval_agent import RetrievalAgent
from .generation_agent import GenerationAgent
from .feedback_agent import FeedbackAgent

class OrchestratorAgent(Agent):
    def __init__(self, logger, config, model_name="gemini-2.0-flash"):
        super().__init__("OrchestratorAgent", logger)
        self.config = config
        self.retrieval_agent = RetrievalAgent(logger, config)
        self.generation_agent = GenerationAgent(logger, model_name)
        self.feedback_agent = FeedbackAgent(logger)

    async def execute(self, input_data, context=None):
        mode = input_data["mode"]
        question = input_data["question"]
        to_db = input_data["to_db"]
        max_iterations = self.config['max_iterations'] if mode == "2" else 1
        cur_iter = 0
        log = []

        while cur_iter < max_iterations:
            cur_iter += 1
            self.logger.info(f"Starting iteration {cur_iter}")
            # Step 1: Retrieve documents
            retrieval_result = await self.retrieval_agent.execute({
                "question": question,
                "mode": mode
            })
            log.append(f"Retrieved {len(retrieval_result['docs'])} documents")

            # Step 2: Generate CLI commands
            generation_result = await self.generation_agent.execute({
                "question": question,
                "mode": mode,
                "context": retrieval_result["context"],
                "cur_iter": cur_iter
            })
            log.append(f"Generated: {generation_result['output']}")

            # Step 3: Validate and get feedback
            feedback_result = await self.feedback_agent.execute({
                "output": generation_result["output"],
                "to_db": to_db,
                "docs": retrieval_result["docs"],
                "mode": mode
            })
            if mode == "1" or not feedback_result["continue_iteration"]:
                return {
                    "output": feedback_result["validated_outputs"],
                    "log": "\n".join(log)
                }


        return {
            "output": feedback_result["validated_outputs"],
            "log": "\n".join(log)
        }
