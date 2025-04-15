import json, os, re, ast
from langchain_community.vectorstores import FAISS
from langchain.prompts import ChatPromptTemplate
from langchain.schema.runnable import RunnablePassthrough
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.document_loaders import PyPDFLoader
from langchain_huggingface import HuggingFaceEmbeddings
from langchain.schema import Document
from langchain_core.output_parsers import StrOutputParser
import os
parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
res_path = os.path.join(parent_path, "res")

pdf_file = rf"{res_path}\\Cli script guidebook.pdf"
loader = PyPDFLoader(pdf_file)
pdf_docs = loader.load_and_split()

with open(rf"{res_path}\\data_mapping.json", "r") as f:
    data_mapping = json.load(f)

REFERENCE_KEYWORDS = list(data_mapping.keys())

data_mapping_doc = Document(page_content='Default Arguments for each node:\n'+ json.dumps(data_mapping))

all_docs = pdf_docs + [data_mapping_doc]

embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
vectorstore = FAISS.from_documents(documents=all_docs, embedding=embeddings)
retriever = vectorstore.as_retriever()

def get_llm(model_name="gemini-1.5-pro"):
    return ChatGoogleGenerativeAI(
        model=model_name,
        temperature=0.1,
        max_output_tokens=500,
        google_api_key=os.getenv("GOOGLE_API_KEY")
    )

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

def combine_inputs(input_dict, retriever):
    question = input_dict["question"]
    retrieved_docs = retriever.invoke(question)
    return {
        "context": format_docs(retrieved_docs),
        "question": question
    }

def parse_command_list(output: str):
    pattern = r"\[(.*?)\]"
    matches = re.findall(pattern, output, re.DOTALL)

    if matches:
        output = f"[{matches[0]}]"

    try:
        command_list = ast.literal_eval(output.strip())
        return command_list if isinstance(command_list, list) else [command_list]
    except Exception as e:
        return [f"Failed to parse: {e}"]


template = """You are an expert assistant trained to extract exact command-line instructions from a user guide.

You are given the folliwing information:
- A user guide that contains command-line instructions for a CLI tool.
- all possible values for node_name
- mapping of node names to their default arguments.

Reference Information:
{context}

User Query:
{question}

Instructions:
- Carefully read the Reference Information, node names, and default arguments for each node.
- Return the CLI command(s) that are relevant to the user's query.
- Format your response as a raw Python list: ['command1', 'command2', ...]
- Do NOT include any explanations, comments, or formatting outside the list.
- If no command matches the query, return an empty list: []
- The output MUST be ordered in the same order as the input.

Example Query:
I want to make a logistic regression model and make a project with id 3.

Expected Response:
[
    'make logistic_regression <args>',
    'create_project 3'
]
"""

prompt = ChatPromptTemplate.from_template(template)
def create_rag_chain(model_name, retriever):
    """Creates a RAG chain with the specified model_name."""
    return (
    RunnablePassthrough()
    | (lambda x: combine_inputs(x, retriever))
    | prompt
    | get_llm(model_name=model_name)
    | StrOutputParser()
    | parse_command_list
)

def run_pipeline(user_query: str, model_name):
    rag_chain = create_rag_chain(model_name, retriever)
    return rag_chain.invoke({"question": user_query}), user_query, REFERENCE_KEYWORDS, data_mapping
