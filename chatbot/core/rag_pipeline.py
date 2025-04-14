import json, os
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
with open(rf"{res_path}\\mapping.json", "r") as f:
    raw_mapping = json.load(f)
with open(rf"{res_path}\\data_mapping.json", "r") as f:
    data_mapping = json.load(f)

REFERENCE_KEYWORDS = list(raw_mapping.keys())
mapping_text = "\n".join(f"{k} -> {v}" for k, v in raw_mapping.items())
mapping_doc = Document(page_content=mapping_text)

loader = PyPDFLoader(pdf_file)
pdf_docs = loader.load_and_split()
all_docs = pdf_docs + [mapping_doc]

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

def combine_inputs(input_dict):
    question = input_dict["question"]
    retrieved_docs = retriever.invoke(question)
    return {
        "context": format_docs(retrieved_docs),
        "question": question
    }

template = """You are an expert assistant trained to extract exact command-line instructions from a user guide.

You are also provided with a node-to-subcommand mapping reference (e.g., "logistic_regression" → "model", "standard_scaler" → "preprocessor"). Use this mapping only to determine the correct value for <node_name> in the CLI command syntax.

Reference Information:
{context}

User Query:
{question}

Instructions:
- Carefully read the Reference Information, including any node-to-subcommand mappings and CLI usage documentation.
- Return the CLI command(s) that are relevant to the user's query with the node name in the node-to subcommand mapping.
- Use the mapping to replace <node_name> with its corresponding type (e.g., model, preprocessor, etc.)
- IMPORTANT: Never modify or replace <args>. Keep <args> exactly as it is shown.
- Format your response as a raw Python list: ['command1', 'command2', ...]
- Do NOT include any explanations, comments, or formatting outside the list.
- If no command matches the query, return an empty list: []
- The output MUST be ordered in the same order as the input.

Example Query:
I want to make a logistic regression model.

Expected Response:
[
    ('make model <args>', 'logistic_regression')
]
"""

prompt = ChatPromptTemplate.from_template(template)
rag_chain = (
    RunnablePassthrough()
    | combine_inputs
    | prompt
    | get_llm(model_name="gemini-2.0-flash")
    | StrOutputParser()
)

def run_pipeline(user_query: str):
    return rag_chain.invoke({"question": user_query}), user_query, REFERENCE_KEYWORDS, raw_mapping, data_mapping
