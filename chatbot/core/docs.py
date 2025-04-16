import os, json
from langchain_community.document_loaders import PyPDFLoader
from langchain.schema import Document

parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
res_path = os.path.join(parent_path, "res")

def get_docs(choice):
    pdf_file = rf"{res_path}\\Cli script guidebook.pdf"
    loader = PyPDFLoader(pdf_file)
    pdf_docs = loader.load_and_split()

    with open(rf"{res_path}\\data_mapping.json", "r") as f:
        data_mapping = json.load(f)
    data_mapping_doc = Document(page_content='Default Arguments for each node:\n'+ json.dumps(data_mapping))
    final_doc = pdf_docs + [data_mapping_doc]
    
    if choice == '2':
        steps_file = rf"{res_path}\\steps.pdf"
        steps_loader = PyPDFLoader(steps_file)

        steps_docs = steps_loader.load_and_split()
        final_doc = steps_docs + [data_mapping_doc]
        final_doc += [Document(page_content='')]
    return final_doc
