import os
from chatbot.core.rag_pipeline import get_llm
from langchain.prompts import ChatPromptTemplate
from chatbot.agents.orchestrator import OrchestratorAgent
from chatbot.agents.router_agent import RouterAgent
from langchain_core.output_parsers import StrOutputParser
from chatbot.core.utils import load_config, init_logger

config = load_config('config/config.yaml')
chat_config = config['chat']

logger = init_logger(__name__, config)

chat_model = get_llm(
    model_name=chat_config['model'],
    temperature=chat_config['temperature'],
    max_tokens=chat_config['max_tokens'],
    google_key=os.getenv("GOOGLE_API_KEY")
    )

chat_prompt = ChatPromptTemplate.from_template("Your name is AINO, Answer the following query conversationally:\n{query} use the context if needed:\n{context}")
chat_chain = (
    chat_prompt 
    | chat_model 
    | StrOutputParser()
    )

async def process_query(user_input, to_db, model, chat_history):
    router = RouterAgent(logger, config)
    orchestrator = OrchestratorAgent(logger, config, model_name=model)
    
    # Store chat history
    chat_history = chat_history or []
    
    # Route the query either chat or agent
    route_result = await router.execute({"question": user_input})
    route = route_result["route"]
    print(f"Route Selected: {route}")

    if route == "chat":
        logger.info("Processing as chat query")
        response = await chat_chain.ainvoke({"query": user_input, "context": chat_history})
        chat_history.append({"user": user_input, "bot": response})
        return response, "", chat_history
    
    # Process CLI query
    logger.info("Processing as CLI query")
    result = await orchestrator.execute({
        "question": user_input,
        "to_db": to_db
    })
    chat_history.append({"user":user_input, "bot": f"Generated CLI Commands:\n{result['output']}\n\nLog:\n{result['log']}"})
    return result["output"], result["log"], chat_history
