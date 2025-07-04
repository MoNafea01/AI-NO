<<<<<<< HEAD
from .agents import Agent
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
=======
import os
from .agents import Agent, retriever_class
from langchain_community.vectorstores import FAISS
>>>>>>> main
from chatbot.core.docs import get_docs

# RetrievalAgent for handling document retrieval based on user queries
# It uses a vector store to retrieve relevant documents based on the user's question.
class RetrievalAgent(Agent):
    def __init__(self, logger, config, cache_dir="retriever_cache"):
        super().__init__("RetrievalAgent", logger)
        self.config = config
        self.cache_dir = cache_dir
        self.retriever_cache = {}
        self.embeddings = retriever_class
        
        os.makedirs(self.cache_dir, exist_ok=True)

    async def execute(self, input_data, context=None):
        query = input_data["question"]
        mode = input_data["mode"]
        cache_key = mode if isinstance(mode, str) else f"{mode}"
        retriever_path = os.path.join(self.cache_dir, mode)
        docs = input_data.get("docs", None)
        
        if docs:
            cache_key = f"{mode}_{len(docs[-1].page_content)}"

        if cache_key in self.retriever_cache:
            self.logger.debug(f"Using cached retriever for {cache_key}")
            retriever = self.retriever_cache[cache_key]
            
        if os.path.exists(retriever_path) and not docs:
            self.logger.info(f"Loading FAISS retriever from disk for mode: {cache_key}")
            vectorstore = FAISS.load_local(retriever_path, embeddings=self.embeddings, allow_dangerous_deserialization=True)
            retriever = vectorstore.as_retriever(search_kwargs={"k": self.config['retrieval']['top_k']})
            self.retriever_cache[cache_key] = retriever
            
        else:
            save_flag = not(docs)
            if not docs:
                docs = get_docs(mode)
            vectorstore = FAISS.from_documents(documents=docs, embedding=self.embeddings)
            
            if save_flag:
                vectorstore.save_local(retriever_path)
            
            retriever = vectorstore.as_retriever(search_kwargs={"k": self.config['retrieval']['top_k']})
            self.retriever_cache[cache_key] = retriever
            self.logger.info(f"Created new retriever for {cache_key}")

        # Hybrid search: Combine semantic and keyword-based retrieval
        retrieved_docs = retriever.invoke(query)
        # Optional: Rerank documents using a cross-encoder
        self.logger.debug(f"Retrieved {len(retrieved_docs)} documents")
        return {"docs": retrieved_docs, "context": "\n\n".join(doc.page_content for doc in retrieved_docs)}
