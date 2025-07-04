from .agents import Agent
from .retrieval_agent import RetrievalAgent
from .generation_agent import GenerationAgent
from .feedback_agent import FeedbackAgent
from .steps_estimator import StepsEstimateAgent
from .mode_selector_agent import ModeSelectorAgent

# OrchestratorAgent for coordinating the workflow of the chatbot
# It manages the retrieval of documents, generation of CLI commands, and feedback processing.
class OrchestratorAgent(Agent):
    def __init__(self, logger, config, model_name="gemini-2.0-flash"):
        super().__init__("OrchestratorAgent", logger)
        self.config = config
        self.retrieval_agent = RetrievalAgent(logger, config)
        self.generation_agent = GenerationAgent(logger, model_name)
        self.feedback_agent = FeedbackAgent(logger)
        self.steps_estimate_agent = StepsEstimateAgent(logger, config)
        self.mode_selector_agent = ModeSelectorAgent(logger, config)

    async def execute(self, input_data, context=None):
        question = input_data["question"]
        
        mode_selector_result = await self.mode_selector_agent.execute({"question": question})
        mode = mode_selector_result["mode"]
        print(f"Mode  Selected: {mode}")
                
        to_db = input_data["to_db"]
        if mode == 'auto':
            max_iterations = await self.steps_estimate_agent.execute({'question': question})
            print(f"Max Iterations: {max_iterations}")
        else:
            max_iterations = 1
        
        cur_iter = 0
        log = []
        docs = None
        while cur_iter < max_iterations:
            cur_iter += 1
            self.logger.info(f"Starting iteration {cur_iter}")
            # Step 1: Retrieve documents
            retrieval_result = await self.retrieval_agent.execute({
                "question": question,
                "mode": mode,
                "docs": docs
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
            print("Model   Output: ", generation_result['output'])

            # Step 3: Validate and get feedback
            feedback_result = await self.feedback_agent.execute({
                "output": generation_result["output"],
                "to_db": to_db,
                "docs": retrieval_result["docs"],
                "mode": mode
            })
<<<<<<< HEAD
=======
            
            docs = feedback_result["updated_docs"]
>>>>>>> main
            if mode == "manual" or not feedback_result["continue_iteration"]:
                return {
                    "output": feedback_result["validated_outputs"],
                    "log": "\n".join(log)
                }


        return {
            "output": feedback_result["validated_outputs"],
            "log": "\n".join(log)
        }
