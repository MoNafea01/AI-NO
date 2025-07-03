import ast
import asyncio
from .agents import Agent
from cli.call_cli import call_script
from chatbot.core.utils import parse_command_list, extract_id_message, handle_params

# FeedbackAgent for processing user feedback on CLI commands
# It validates the commands, interacts with the CLI, and updates documents accordingly.
class FeedbackAgent(Agent):
    def __init__(self, logger):
        super().__init__("FeedbackAgent", logger)

    async def execute(self, input_data, context=None):
        output = handle_params(input_data["output"])
        to_db = input_data["to_db"]
        docs = input_data["docs"]
        mode = input_data["mode"]

        # Parse and validate CLI commands
        if mode == "manual":
            commands = parse_command_list(output)
        elif mode == "auto":
            commands = [output]
            
        validated_outputs = []
        continue_iteration = True

        for cmd in commands:
            if to_db:
                if cmd in ['done', 'Done', 'done!', 'Done!']:
                    continue_iteration = False
                    break
                call_script_response = await asyncio.to_thread(call_script, cmd)
                
                api_response = extract_id_message(call_script_response)
                validated_outputs.append(api_response)
                # Update last document with API response
                try:
                    response_list = ast.literal_eval(api_response)
                    if isinstance(response_list, list):
                        for element in response_list:
                            docs[-1].page_content += str(element) + "\n"
                except:
                    docs[-1].page_content += str(api_response) + "\n"
            else:
                validated_outputs.append(cmd)

        # Assign confidence score (simplified example)

        return {
            "validated_outputs": validated_outputs,
            "updated_docs": docs,
            "continue_iteration": continue_iteration
        }
