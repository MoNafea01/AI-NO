import os, re, ast
from langchain_community.vectorstores import FAISS
from langchain.prompts import ChatPromptTemplate
from langchain.schema.runnable import RunnablePassthrough
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.output_parsers import StrOutputParser
from core.templates import get_template


def get_llm(model_name="gemini-1.5-pro"):
    return ChatGoogleGenerativeAI(
        model=model_name,
        temperature=0.1,
        max_output_tokens=500,
        google_api_key=os.getenv("GOOGLE_API_KEY")
    )

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

def combine_inputs(input_dict, retriever, cur_iter=0):
    question = input_dict["question"]
    retrieved_docs = retriever.invoke(question)
    return {
        "context": format_docs(retrieved_docs),
        "question": question,
        "cur_iter": cur_iter
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


def create_rag_chain(docs, cur_iter, model_name, selected_mode):
    """Creates a RAG chain with the specified model_name."""
    model = get_llm(model_name=model_name)
    template = get_template(selected_mode)
    prompt = ChatPromptTemplate.from_template(template)

    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
    retriever = FAISS.from_documents(documents=docs, embedding=embeddings).as_retriever()

    return (
    RunnablePassthrough()
    | (lambda x: combine_inputs(x, retriever, cur_iter))
    | prompt
    | model
    | StrOutputParser()
)

def run_pipeline(docs, question: str, model_name, selected_mode, cur_iter=0):

    rag_chain = create_rag_chain(docs, cur_iter, model_name, selected_mode)
    return rag_chain.invoke({"question": question, "cur_iter": cur_iter})
