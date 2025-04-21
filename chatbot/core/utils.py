#chatbot/core/utils.py

import json
import re, ast
from cli.call_cli import call_script

MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer"]

def extract_id_message(json_str):
    out = []
    try:
        if isinstance(json_str, str):
            json_obj = json.loads(json_str)
        elif isinstance(json_str, dict):
            json_obj = json_str
        message = json_obj.get("message")
        node_id = json_obj.get("node_id")

        if json_obj.get("node_name") in MULTI_CHANNEL_NODES:
            for i in range(len(json_obj.get("children", []))):
                child = call_script(f"show {json_obj.get("node_name")} {node_id} {i+1}")
                try:
                    child_message = child.get("message")
                    child_node_id = child.get("node_id")
                    if child_message:
                        out.append({"message": child_message, "node_id": child_node_id})
                except Exception as e:
                    print(f"Error processing child node: {e}")
                    continue


        json_obj = {"message": message, "node_id": node_id}
        out.append(json_obj)
        return f'{out}'
    
    except:
        return json_str

    

def parse_command_list(output: str):
    pattern = r"\[(.*?)\]"
    matches = re.findall(pattern, output, re.DOTALL)

    if matches:
        output = f"[{matches[0]}]"

    try:
        command_list = ast.literal_eval(output.strip())
        return command_list if isinstance(command_list, list) else [command_list]
    except Exception as e:
        return [f"Failed to parse command list. Error: {e}. Raw output: {output}"]

