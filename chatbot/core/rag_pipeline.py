# #chatbot/core/rag_pipeline.py
from langchain_community.vectorstores import FAISS
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_ollama import OllamaLLM
from langchain_huggingface import HuggingFaceEmbeddings
from chatbot.core.utils import init_logger, load_config

# # Configure logging
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)


def get_llm(model_name="gemini-1.5-pro", temperature=0.1, max_tokens=500, google_key=None):
    logger.info(f"Initializing LLM: {model_name}")
    
    try:
        if model_name.startswith("gemini"):
            llm = ChatGoogleGenerativeAI(
                model=model_name,
                temperature=temperature,
                max_output_tokens=max_tokens,
                google_api_key=google_key
            )
            
        elif model_name.startswith("deepseek"):
            llm = OllamaLLM(
                model=model_name, 
                temperature=0.1
            )
            
        else:
            raise ValueError(f"Unsupported model: {model_name}")

        logger.debug("LLM initialized successfully")
        return llm
    
    except Exception as e:
        logger.error(f"Failed to initialize LLM: {str(e)}")
        raise


def format_docs(docs):
    logger.debug(f"Formatting {len(docs)} documents")
    return "\n\n".join(doc.page_content for doc in docs)

def combine_inputs(input_dict, retriever, cur_iter=0):
    question = input_dict["question"]
    logger.info(f"Processing question: {question}")
    try:
        retrieved_docs = retriever.invoke(question)
        logger.debug(f"Retrieved {len(retrieved_docs)} documents")
        return {
            "context": format_docs(retrieved_docs),
            "question": question,
            "cur_iter": cur_iter
        }
    except Exception as e:
        logger.error(f"Error in combine_inputs: {str(e)}")
        raise

retriever_cache = {}

def get_retriever(docs, key="default"):
    logger.info(f"Getting retriever for key: {key}")
    if key in retriever_cache:
        logger.debug("Returning cached retriever")
        return retriever_cache[key]

    try:
        logger.debug("Initializing new retriever")
        embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
        vectorstore = FAISS.from_documents(documents=docs, embedding=embeddings)
        retriever = vectorstore.as_retriever(search_kwargs={"k": 5})
        retriever_cache[key] = retriever
        return retriever
    except Exception as e:
        logger.error(f"Error creating retriever: {str(e)}")
        raise


# def create_rag_chain(docs, cur_iter, model_name, selected_mode):
#     """Creates a RAG chain with the specified model_name."""
#     logger.info(f"Creating RAG chain for mode: {selected_mode}, iteration: {cur_iter}")

#     try:
#         model = get_llm(model_name=model_name)
#         template = get_template(selected_mode)
#         prompt = ChatPromptTemplate.from_template(template)

#         retriever = get_retriever(docs, key=selected_mode)

#         rag_chain = (
#             RunnablePassthrough()
#             | (lambda x: combine_inputs(x, retriever, cur_iter))
#             | prompt
#             | model
#             | StrOutputParser()
#         )
#         logger.debug("RAG chain created successfully")
#         return rag_chain
    
#     except Exception as e:
#         logger.error(f"Error creating RAG chain: {str(e)}")
#         raise


# def run_pipeline(docs, question: str, model_name, selected_mode, cur_iter=0):
#     logger.info(f"Running pipeline for question: {question}")
    
#     try:
#         rag_chain = create_rag_chain(docs, cur_iter, model_name, selected_mode)
#         result = rag_chain.invoke({"question": question, "cur_iter": cur_iter})
#         logger.info("Pipeline execution completed")
#         return result
    
#     except Exception as e:
#         logger.error(f"Error running pipeline: {str(e)}")
#         raise
