#chatbot/app.py
import gradio as gr, ast
from __init__ import *
from chatbot.core.utils import init_logger, load_config, parse_command_list, call_script, extract_id_message
from chatbot.core.docs import get_docs
from chatbot.core.rag_pipeline import run_pipeline, get_llm
from chatbot.agents.orchestrator import OrchestratorAgent
from chatbot.agents.router_agent import RouterAgent
from chatbot.agents.clarification_agent import ClarificationAgent

from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Configure logging
parent_path = os.path.dirname(os.path.abspath(__file__))
cb_logs_path = os.path.join(parent_path, "chatbot_logs.txt")
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

chat_config = config['chat']
chat_model = get_llm(
    model_name=chat_config['model'],
    temperature=chat_config['temperature'],
    max_tokens=chat_config['max_tokens'],)

chat_prompt = ChatPromptTemplate.from_template("Answer the following query conversationally:\n{query} use the context if needed:\n{context}")
chat_chain = (
    chat_prompt 
    | chat_model 
    | StrOutputParser()
    )

def sync_generate_cli(user_input, to_db, model, selected_mode, cur_iter, route='chat', history=None):
    logger.info(f"Generating CLI commands for mode: {selected_mode}, model: {model}")
    MANUAL = '1'
    AUTO = '2'
    if route in ['agent', '2']:
        try:
            if selected_mode == MANUAL:
                logger.debug("Processing in manual mode")
                return manual_mode(user_input, model, to_db)
            
            elif selected_mode == AUTO:
                logger.debug("Processing in auto mode")
                return auto_mode(user_input, model, to_db, cur_iter)
            
        except Exception as e:
            logger.exception(f"Error in generate_cli: {str(e)}")
            raise
    
    elif route in ['chat', '1']:
        if isinstance(history, list):
            l = []
            for d in history:
                print(d)
                if isinstance(d, dict):
                    d = {k: v for k, v in d.items()}
                l.append(str(d))
            context = "\n".join(l)
        else:
            context = "initial context"
        
        logger.debug("Processing in chat mode")
        response = chat_chain.invoke({"query": user_input, "context": context})
        history.append({"user": user_input, "bot": response})
        return response, None, history


def manual_mode(question, model, to_db):
    logger.info(f"Running manual mode for question: {question}")
    try:
        docs = get_docs('1')
        logger.debug(f"Loaded {len(docs)} documents for manual mode")

        rag_output = run_pipeline(docs, question, model, selected_mode="1", cur_iter=0)
        rag_output = parse_command_list(rag_output)
        logger.info(f"Parsed {len(rag_output)} RAG outputs")

        log = ""
        def log_msg_inner(msg, *args, **kwargs):
            nonlocal log
            print(msg, *args, **kwargs)
            log += msg + "\n"
            logger.debug(f"Log message: {msg}")

        log_msg_inner(f"RAG Output : \n" + str(rag_output), end='\n\n')

        out = []
        for i, output in enumerate(rag_output):
            cmd = output
            if to_db:
                logger.debug(f"Calling script for output {i+1}: {output}")
                cmd = call_script(output)
            out.append(cmd)

            log_msg_inner(f"\nAPI Output {i+1}: \n" + str(cmd), end='\n')

        log_msg_inner('-'*50)

        logger.debug("Writing log to chatbot_logs.txt")
        with open(cb_logs_path, "a", encoding="utf-8") as f:
            f.write(log)
            f.write("\n\n")

        logger.info("Manual mode processing completed")
        return out, log, None
    except Exception as e:
        logger.exception(f"Error in manual_mode: {str(e)}")
        raise

def auto_mode(question, model, to_db, cur_iter):
    logger.info(f"Running auto mode for question: {question}, iteration: {cur_iter}")
    try:
        docs = get_docs('2')
        logger.debug(f"Loaded {len(docs)} documents for auto mode")

        log = ""
        def log_msg_inner(msg, *args, **kwargs):
            nonlocal log
            print(msg, *args, **kwargs)
            log += msg + "\n"
            logger.debug(f"Log message: {msg}")

        if not to_db:
            msg = "Auto mode is not supported without DB."
            logger.warning(msg)
            log_msg_inner(msg)
            with open(cb_logs_path, "a", encoding="utf-8") as f:
                f.write(log)
                f.write("\n\n")

            return msg, log, None
        
        while cur_iter < 10:
            cur_iter += 1
            logger.debug(f"Processing iteration {cur_iter}")
            rag_output= run_pipeline(docs, question, model, selected_mode="2", cur_iter=cur_iter)
            rag_output = rag_output.strip().strip("'").strip('"')
            log_msg_inner(f"RAG Output {cur_iter}: \n" + str(rag_output), end='\n\n')

            logger.debug(f"Calling script for RAG output: {rag_output}")
            api_response = extract_id_message(call_script(rag_output))
            try:
                response_list = ast.literal_eval(api_response)
                if isinstance(response_list, list):
                    for element in response_list:
                        docs[-1].page_content += str(element) + "\n"
            except:
                docs[-1].page_content += str(api_response) + "\n"

            logger.debug(f"Updated last document page content")
            log_msg_inner(f"API Response {cur_iter}: " + str(api_response))
            log_msg_inner('-'*50)

        logger.debug("Writing log to chatbot_logs.txt")
        with open(cb_logs_path, "a", encoding="utf-8") as f:
            f.write(log)
            f.write("\n\n")

        logger.info("Auto mode processing completed")
        return rag_output, log, None
    
    except Exception as e:
        logger.exception(f"Error in auto_mode: {str(e)}")
        raise

async def process_query(user_input, route, to_db, model, selected_mode, chat_history):
    # router = RouterAgent(logger, config)
    # clarification = ClarificationAgent(logger, config)
    orchestrator = OrchestratorAgent(logger, config, model_name=model)
    
    # Store chat history
    chat_history = chat_history or []
    chat_history.append(("user", user_input))
    
    # Route the query
    # route_result = await router.execute({"question": user_input})
    # route = route_result["route"]
    # print(f"Route: {route}")
    # query = route_result["query"]
    
    routes = {
        "chat": "1",
        "agent": "2",
    }

    if route  == routes["chat"]:
        logger.info("Processing as chat query")
        response = await chat_chain.ainvoke({"query": user_input})
        chat_history.append(("bot", response))
        return "", response, chat_history
    
    # Check for clarification
    # clarification_result = await clarification.execute({"query": query})
    # if clarification_result["status"] == "needs_clarification":
    #     logger.info("Query needs clarification")
    #     chat_history.append(("bot", clarification_result["prompt"]))
    #     return "", clarification_result["prompt"], chat_history
    
    # Process CLI query
    logger.info("Processing as CLI query")
    result = await orchestrator.execute({
        "question": user_input,
        "mode": selected_mode,
        "to_db": to_db
    })
    chat_history.append(("bot", f"Generated CLI Commands:\n{result['output']}\n\nLog:\n{result['log']}"))
    return result["output"], result["log"], chat_history

# async def generate_cli(user_input, to_db, model, selected_mode):
#     orchestrator = OrchestratorAgent(logger, config, model_name=model)
    
#     result = await orchestrator.execute({
#         "question": user_input,
#         "mode": selected_mode,
#         "to_db": to_db
#     })
#     return result["output"], result["log"]


def run_app():
    logger.info("Starting CLI Generator Assistant application")
    with gr.Blocks(title="CLI Generator Assistant") as app:
        gr.Markdown("# 🤖 Node Generator Agent")
        send_to_db = gr.Checkbox("Send Prompts to Database", value=True, label="Send to DB")
        select_mode = gr.Radio(label="Select Mode", choices=[("Manual", "1"), ("Auto", "2")], value="1")
        model = gr.Dropdown(
            label="Select a Model",
            choices=config['models'],
            value=config['models'][2]
        )
        route = gr.Radio(label="Chat or Agent",choices=[("Chat", "1"), ("Agent", "2")], value="1")
        user_input = gr.Textbox(lines=3, label="Describe your pipeline or ask a question")
        final_output = gr.Textbox(label="Final CLI Commands")
        log_output = gr.Textbox(lines=10, label="Log", interactive=False)
        chat_history = gr.State([])

        btn = gr.Button("Submit")
        btn.click(
            fn=process_query,
            inputs=[user_input, route, send_to_db, model, select_mode, chat_history],
            outputs=[final_output, log_output, chat_history]
        )

        logger.info("Launching Gradio application")
        app.launch()

if __name__ == "__main__":
    logger.info("Initializing application")
    run_app()
