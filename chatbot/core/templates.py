#chatbot/core/templates.py
import os
from chatbot.core.utils import init_logger, load_config
# Configure logging
parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
template_dir = os.path.join(parent_path, 'templates')
config = load_config('config/config.yaml')

def get_template(mode):
    logger = init_logger(__name__, config)
    logger.info(f"Loading template for mode: {mode}")
    file_map = {
        '1': config['templates']['manual'],
        '2': config['templates']['auto'],
        '3': config['templates']['data_steps'],
        '4': config['templates']['router'],
        '5': config['templates']['select_mode']
    }
    template_path = os.path.join(template_dir, file_map[mode])
    logger.debug(f"Template path: {template_path}")
    try:
        if not os.path.exists(template_path):
            logger.error(f"Template file not found: {template_path}")
            raise FileNotFoundError(f"Template file for mode {mode} not found.")

        with open(template_path, 'r') as file:
            template = file.read()
        logger.info(f"Template loaded successfully for mode {mode}")
        return template
    except Exception as e:
        logger.error(f"Error loading template: {str(e)}")
        raise
