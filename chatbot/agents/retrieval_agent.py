from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from .agents import Agent
from chatbot.core.docs import get_docs

class RetrievalAgent(Agent):
    def __init__(self, logger, config, cache_dir="retriever_cache"):
        super().__init__("RetrievalAgent", logger)
        self.config = config
        self.cache_dir = cache_dir
        self.retriever_cache = {}
        self.embeddings = HuggingFaceEmbeddings(model_name=self.config['retrieval']['embedding_model'])

    async def execute(self, input_data, context=None):
        query = input_data["question"]
        mode = input_data["mode"]
        cache_key = f"{mode}_{query}"

        if cache_key in self.retriever_cache:
            self.logger.debug(f"Using cached retriever for {cache_key}")
            retriever = self.retriever_cache[cache_key]
        else:
            docs = get_docs(mode)
            vectorstore = FAISS.from_documents(documents=docs, embedding=self.embeddings)
            retriever = vectorstore.as_retriever(search_kwargs={"k": self.config['retrieval']['top_k']})
            self.retriever_cache[cache_key] = retriever
            self.logger.info(f"Created new retriever for {cache_key}")

        # Hybrid search: Combine semantic and keyword-based retrieval
        retrieved_docs = retriever.invoke(query)
        # Optional: Rerank documents using a cross-encoder
        self.logger.debug(f"Retrieved {len(retrieved_docs)} documents")
        return {"docs": retrieved_docs, "context": "\n\n".join(doc.page_content for doc in retrieved_docs)}
