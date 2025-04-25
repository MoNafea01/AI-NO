#chatbot/core/docs.py

import os
import json
from langchain_community.document_loaders import PyPDFLoader
from langchain.schema import Document
from chatbot.core.utils import init_logger

# Configure logging
parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
log_file = os.path.join(parent_path, "aino_logs.log")
logger = init_logger(__name__, log_file)

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

        if choice == '1':
            logger.info("Returning manual mode documents")
            return pdf_docs + [data_mapping_doc]
        
        elif choice == '2':
            steps_file = os.path.join(res_path, "steps.pdf")
            logger.debug(f"Loading steps PDF from: {steps_file}")
            steps_loader = PyPDFLoader(steps_file)
            steps_docs = steps_loader.load_and_split()
            logger.info(f"Successfully loaded {len(steps_docs)} pages from steps PDF")

            logger.info("Returning auto mode documents")
            return steps_docs + pdf_docs + [data_mapping_doc] + [Document(page_content='')]

        else:
            logger.error(f"Invalid mode choice: {choice}")
            raise ValueError("Invalid mode choice. Must be '1' (manual) or '2' (auto).")
    except Exception as e:
        logger.exception(f"Error in get_docs: {str(e)}")
        raise 
    