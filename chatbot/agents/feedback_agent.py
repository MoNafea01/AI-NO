from .agents import Agent
from chatbot.core.utils import parse_command_list, extract_id_message
from cli.call_cli import call_script
import ast

class FeedbackAgent(Agent):
    def __init__(self, logger):
        super().__init__("FeedbackAgent", logger)

    async def execute(self, input_data, context=None):
        output = input_data["output"]
        to_db = input_data["to_db"]
        docs = input_data["docs"]
        mode = input_data["mode"]

        # Parse and validate CLI commands
        if mode == "1":
            commands = parse_command_list(output)
        elif mode == "2":
            commands = [output]
            
        validated_outputs = []
        continue_iteration = True

        for cmd in commands:
            if to_db:
                if cmd in ['done', 'Done', 'done!', 'Done!']:
                    continue_iteration = False
                    break

                api_response = extract_id_message(call_script(cmd))
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
