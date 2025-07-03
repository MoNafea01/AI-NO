#chatbot/core/docs.py

import os
import json
from langchain_community.document_loaders import PyPDFLoader
from langchain.schema import Document
from chatbot.core.utils import init_logger
from chatbot.core.utils import load_config

# Configure logging
parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

res_path = os.path.join(parent_path, "res")

def get_docs(choice):
    logger.info(f"Loading documents for choice: {choice}")

    try:
        
        pdf_file = os.path.join(res_path, "Cli script guidebook.pdf")
        logger.debug(f"Loading PDF from: {pdf_file}")

        loader = PyPDFLoader(pdf_file)
        pdf_docs = loader.load_and_split()
        logger.info(f"Successfully loaded {len(pdf_docs)} pages from Cli script guidebook")

        data_mapping_path = os.path.join(res_path, 'data_mapping.json')
        logger.debug(f"Loading data mapping from: {data_mapping_path}")

        with open(data_mapping_path, 'r') as f:
            data_mapping = json.load(f)
        logger.info("Successfully loaded data mapping")

        data_mapping_doc = Document(page_content='Default Arguments for each node:\n' + 
                                    json.dumps(data_mapping))
        logger.debug("Created data mapping document")

        if choice in ['manual', 'router']:
            logger.info("Returning manual mode documents")
            return pdf_docs + [data_mapping_doc]
        
        elif choice in ['auto', 'step', 'selector']:
            steps_file = os.path.join(res_path, "steps.pdf")
            logger.debug(f"Loading steps PDF from: {steps_file}")
            steps_loader = PyPDFLoader(steps_file)
            steps_docs = steps_loader.load_and_split()
            logger.info(f"Successfully loaded {len(steps_docs)} pages from steps PDF")
            if choice in ['auto', 'selector']:
                logger.info("Returning auto mode documents")
                return steps_docs + pdf_docs + [data_mapping_doc] + [Document(page_content='')]
            
            elif choice == 'step':
                logger.info("Returning only data steps document")
                return steps_docs
            
        elif choice == 'auto_mode_nodes':
            logger.info("Returning auto mode nodes documents")
            nodes_file = os.path.join(res_path, "auto_mode_nodes.pdf")
            logger.debug(f"Loading auto mode nodes PDF from: {nodes_file}")
            nodes_loader = PyPDFLoader(nodes_file)
            nodes_docs = nodes_loader.load_and_split()
            logger.info(f"Successfully loaded {len(nodes_docs)} pages from auto mode nodes PDF")
            return nodes_docs
        
        else:
            logger.error(f"Invalid mode choice: {choice}")
            raise ValueError("Invalid mode choice. Must be 'manual' or 'auto'.")
    except Exception as e:
        logger.exception(f"Error in get_docs: {str(e)}")
        raise 
    