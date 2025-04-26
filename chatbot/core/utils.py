#chatbot/core/utils.py

import re
import os
import ast
import json
import logging
import logging.handlers
from cli.call_cli import call_script

MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer"]

def init_logger(name, path):
    log_file = path
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    handler = logging.handlers.RotatingFileHandler(log_file, mode='a', maxBytes=5*1024*1024, backupCount=50)
    handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    logger.addHandler(handler)

    return logger

# Configure logging
parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
log_file = os.path.join(parent_path, "aino_logs.log")
logger = init_logger(__name__, log_file)


def extract_id_message(json_str):
    logger.info("Extracting ID and message from JSON")
    out = []
    try:
        if isinstance(json_str, str):
            logger.debug("Parsing JSON string")
            json_obj = json.loads(json_str)
        elif isinstance(json_str, dict):
            json_obj = json_str
            logger.debug("Processing JSON dictionary")

        message = json_obj.get("message")
        node_id = json_obj.get("node_id")
        logger.debug(f"Extracted message: {message}, node_id: {node_id}")

        if json_obj.get("node_name") in MULTI_CHANNEL_NODES:
            logger.info(f"Processing multi-channel node: {json_obj.get('node_name')}")
            for i in range(len(json_obj.get("children", []))):
                logger.debug(f"Processing child {i+1}")
                child = call_script(f"show {json_obj.get('node_name')} {node_id} {i+1}")

                try:
                    child_message = child.get("message")
                    child_node_id = child.get("node_id")
                    if child_message:
                        out.append({"message": child_message, "node_id": child_node_id})
                        logger.debug(f"Added child message: {child_message}")
                except Exception as e:
                    logger.error(f"Error processing child node {i+1}: {str(e)}")
                    continue

        out.append({"message":message, "node_id": node_id})
        logger.info("Extraction completed successfully")
        return f'{out}'
    
    except Exception as e:
        logger.info(f"Skipped Extraction: {str(e)}")
        return json_str

    

def parse_command_list(output: str):
    logger.info("Parsing command list")
    pattern = r"\[(.*?)\]"
    matches = re.findall(pattern, output, re.DOTALL)

    if matches:
        output = f"[{matches[0]}]"
        logger.debug(f"Extracted command list: {output}")

    try:
        command_list = ast.literal_eval(output.strip())
        logger.info("Command list parsed successfully")
        return command_list if isinstance(command_list, list) else [command_list]
    except Exception as e:
        logger.error(f"Failed to parse command list: {str(e)}. Raw output: {output}")
        return [f"Failed to parse command list. Error: {e}. Raw output: {output}"]
