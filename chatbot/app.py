#chatbot/app.py
import gradio as gr, ast
from __init__ import *
from chatbot.core.utils import init_logger, load_config
from chatbot.core.rag_pipeline import get_llm
from chatbot.agents.orchestrator import OrchestratorAgent
from chatbot.agents.router_agent import RouterAgent

from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Configure logging
parent_path = os.path.dirname(os.path.abspath(__file__))
cb_logs_path = os.path.join(parent_path, "logs", "chatbot_logs.txt")
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

chat_config = config['chat']
chat_model = get_llm(
    model_name=chat_config['model'],
    temperature=chat_config['temperature'],
    max_tokens=chat_config['max_tokens'],
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
    print(f"Route selected: {route}")

    if route == "chat":
        logger.info("Processing as chat query")
        response = await chat_chain.ainvoke({"query": user_input, "context": chat_history})
        chat_history.append({"bot": response, "user": user_input})
        return response, "", chat_history
    
    # Process CLI query
    logger.info("Processing as CLI query")
    result = await orchestrator.execute({
        "question": user_input,
        "to_db": to_db
    })
    chat_history.append(("bot", f"Generated CLI Commands:\n{result['output']}\n\nLog:\n{result['log']}"))
    return result["output"], result["log"], chat_history


def run_app():
    logger.info("Starting CLI Generator Assistant application")
    with gr.Blocks(title="CLI Generator Assistant") as app:
        gr.Markdown("# 🤖 Node Generator Agent")
        send_to_db = gr.Checkbox("Send Prompts to Database", value=True, label="Send to DB")
        model = gr.Dropdown(
            label="Select a Model",
            choices=config['models'],
            value=config['models'][2]
        )
        user_input = gr.Textbox(lines=3, label="Describe your pipeline or ask any question question")
        final_output = gr.Textbox(label="Final Output")
        log_output = gr.Textbox(lines=10, label="Log", interactive=False)
        chat_history = gr.State([])

        btn = gr.Button("Submit")
        btn.click(
            fn=process_query,
            inputs=[user_input, send_to_db, model, chat_history],
            outputs=[final_output, log_output, chat_history]
        )

        logger.info("Launching Gradio application")
        app.launch()

if __name__ == "__main__":
    logger.info("Initializing application")
    run_app()
