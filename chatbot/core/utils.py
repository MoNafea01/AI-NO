#chatbot/core/utils.py

import re, os, ast, json, logging, yaml
import logging.handlers
from cli.call_cli import call_script

MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer"]
parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def init_logger(name, config=None, log_file=None):
    if not config:
        config = {
            'logging': {
                'path': os.path.join(parent_path, "logs","aino_logs.log"),
                'max_bytes': 1024 * 1024 * 5,  # 5 MB
                'backup_count': 5
            }
        }
    log_file = os.path.join(parent_path, config['logging']['path'])
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    handler = logging.handlers.RotatingFileHandler(
        log_file, mode='a', 
        maxBytes=config['logging']['max_bytes'], 
        backupCount=config['logging']['backup_count']
        )
    
    handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    logger.addHandler(handler)

    return logger

log_file = os.path.join(parent_path, "logs", "aino_logs.log")
logger = init_logger(__name__, log_file=log_file)

def load_config(config_path="config.yaml"):
    """
    Load configuration from a YAML file.
    
    Args:
        config_path (str): Path to the YAML configuration file.
        
    Returns:
        dict: Configuration dictionary.
        
    Raises:
        FileNotFoundError: If the config file doesn't exist.
        yaml.YAMLError: If the YAML file is invalid.
    """
    config_path = os.path.join(parent_path, config_path)
    logger.info(f"Loading configuration from {config_path}")
    
    try:
        with open(config_path, 'r') as file:
            config = yaml.safe_load(file)
        logger.debug("Configuration loaded successfully")
        return config
    except FileNotFoundError:
        logger.error(f"Configuration file not found: {config_path}")
        raise
    except yaml.YAMLError as e:
        logger.error(f"Error parsing YAML file: {str(e)}")
        raise

config = load_config(config_path="config/config.yaml")
# Configure logging

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
        out.append({"message":message, "node_id": node_id})

        if json_obj.get("node_name") in MULTI_CHANNEL_NODES:
            logger.info(f"Processing multi-channel node: {json_obj.get('node_name')}")
            for i in range(len(json_obj.get("children", []))):
                logger.debug(f"Processing child {i+1}")
                child = call_script(f"aino --node show {json_obj.get('node_name')} {node_id} {i+1}")

                try:
                    child_message = child.get("message")
                    child_node_id = child.get("node_id")
                    if child_message:
                        out.append({"message": child_message, "node_id": child_node_id})
                        logger.debug(f"Added child message: {child_message}")
                except Exception as e:
                    logger.error(f"Error processing child node {i+1}: {str(e)}")
                    continue

        
        logger.info("Extraction completed successfully")
        return f'{out}'
    
    except Exception as e:
        logger.info(f"Skipped Extraction: {str(e)}")
        return json_str

def load_json_file(file_path):
    """
    Load a JSON file and return its contents.
    
    Args:
        file_path (str): Path to the JSON file.
        
    Returns:
        dict: Contents of the JSON file.
        
    Raises:
        FileNotFoundError: If the file doesn't exist.
        json.JSONDecodeError: If the file is invalid JSON.
    """
    logger = logging.getLogger(__name__)
    full_path = os.path.join(parent_path, file_path)
    logger.info(f"Loading JSON file: {full_path}")
    try:
        with open(full_path, 'r') as f:
            data = json.load(f)
        logger.debug("JSON file loaded successfully")
        return data
    except FileNotFoundError:
        logger.error(f"JSON file not found: {full_path}")
        raise
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in file {full_path}: {str(e)}")
        raise

def parse_command_list(output: str):
    if isinstance(output, list):
        output = str(output)
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


def handle_params(command_line: str):
<<<<<<< HEAD
=======
    if isinstance(command_line, str) and command_line.startswith('```python\n['):
        command_line = ast.literal_eval(command_line[9:-3])
    if isinstance(command_line, list):
        return [_handle_params(cmd) for cmd in command_line]
    return _handle_params(command_line)


def _handle_params(command_line: str):
>>>>>>> main
    if 'params=' in command_line:
        params_str = command_line.split('params=')[1].strip()
        params = ast.literal_eval(params_str)
        if isinstance(params, str):
            try:
                params = ast.literal_eval(params)
            except (ValueError, SyntaxError):
                pass
        if isinstance(params, dict):
            params_str_new = ' '.join([f"{k}={v}" for k, v in params.items() if v is not (None or '' or "")])
            command_line = command_line.replace(f'params={params_str}', params_str_new)

    return command_line
<<<<<<< HEAD

=======
>>>>>>> main
