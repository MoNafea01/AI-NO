#chatbot/app.py
import gradio as gr
from __init__ import *
from chatbot.core.utils import init_logger, load_config
from chatbot.agents.orchestrator import OrchestratorAgent

# Configure logging
parent_path = os.path.dirname(os.path.abspath(__file__))
cb_logs_path = os.path.join(parent_path, "chatbot_logs.txt")
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)


# def generate_cli(user_input, to_db, model, selected_mode, cur_iter):
#     logger.info(f"Generating CLI commands for mode: {selected_mode}, model: {model}")
#     MANUAL = '1'
#     AUTO = '2'

#     try:
#         if selected_mode == MANUAL:
#             logger.debug("Processing in manual mode")
#             return manual_mode(user_input, model, to_db)
        
#         elif selected_mode == AUTO:
#             logger.debug("Processing in auto mode")
#             return auto_mode(user_input, model, to_db, cur_iter)
        
#     except Exception as e:
#         logger.exception(f"Error in generate_cli: {str(e)}")
#         raise

# def manual_mode(question, model, to_db):
#     logger.info(f"Running manual mode for question: {question}")
#     try:
#         docs = get_docs('1')
#         logger.debug(f"Loaded {len(docs)} documents for manual mode")

#         rag_output = run_pipeline(docs, question, model, selected_mode="1", cur_iter=0)
#         rag_output = parse_command_list(rag_output)
#         logger.info(f"Parsed {len(rag_output)} RAG outputs")

#         log = ""
#         def log_msg_inner(msg, *args, **kwargs):
#             nonlocal log
#             print(msg, *args, **kwargs)
#             log += msg + "\n"
#             logger.debug(f"Log message: {msg}")

#         log_msg_inner(f"RAG Output : \n" + str(rag_output), end='\n\n')

#         out = []
#         for i, output in enumerate(rag_output):
#             cmd = output
#             if to_db:
#                 logger.debug(f"Calling script for output {i+1}: {output}")
#                 cmd = call_script(output)
#             out.append(cmd)

#             log_msg_inner(f"\nAPI Output {i+1}: \n" + str(cmd), end='\n')

#         log_msg_inner('-'*50)

#         logger.debug("Writing log to chatbot_logs.txt")
#         with open(cb_logs_path, "a", encoding="utf-8") as f:
#             f.write(log)
#             f.write("\n\n")

#         logger.info("Manual mode processing completed")
#         return out, log
#     except Exception as e:
#         logger.exception(f"Error in manual_mode: {str(e)}")
#         raise

# def auto_mode(question, model, to_db, cur_iter):
#     logger.info(f"Running auto mode for question: {question}, iteration: {cur_iter}")
#     try:
#         docs = get_docs('2')
#         logger.debug(f"Loaded {len(docs)} documents for auto mode")

#         log = ""
#         def log_msg_inner(msg, *args, **kwargs):
#             nonlocal log
#             print(msg, *args, **kwargs)
#             log += msg + "\n"
#             logger.debug(f"Log message: {msg}")

#         if not to_db:
#             msg = "Auto mode is not supported without DB."
#             logger.warning(msg)
#             log_msg_inner(msg)
#             with open(cb_logs_path, "a", encoding="utf-8") as f:
#                 f.write(log)
#                 f.write("\n\n")

#             return msg, log
        
#         while cur_iter < 10:
#             cur_iter += 1
#             logger.debug(f"Processing iteration {cur_iter}")
#             rag_output= run_pipeline(docs, question, model, selected_mode="2", cur_iter=cur_iter)
#             rag_output = rag_output.strip().strip("'").strip('"')
#             log_msg_inner(f"RAG Output {cur_iter}: \n" + str(rag_output), end='\n\n')

#             logger.debug(f"Calling script for RAG output: {rag_output}")
#             api_response = extract_id_message(call_script(rag_output))
#             try:
#                 response_list = ast.literal_eval(api_response)
#                 if isinstance(response_list, list):
#                     for element in response_list:
#                         docs[-1].page_content += str(element) + "\n"
#             except:
#                 docs[-1].page_content += str(api_response) + "\n"

#             logger.debug(f"Updated last document page content")
#             log_msg_inner(f"API Response {cur_iter}: " + str(api_response))
#             log_msg_inner('-'*50)

#         logger.debug("Writing log to chatbot_logs.txt")
#         with open(cb_logs_path, "a", encoding="utf-8") as f:
#             f.write(log)
#             f.write("\n\n")

#         logger.info("Auto mode processing completed")
#         return rag_output, log
    
#     except Exception as e:
#         logger.exception(f"Error in auto_mode: {str(e)}")
#         raise

async def generate_cli(user_input, to_db, model, selected_mode):
    orchestrator = OrchestratorAgent(logger, config, model_name=model)
    result = await orchestrator.execute({
        "question": user_input,
        "mode": selected_mode,
        "to_db": to_db
    })
    return result["output"], result["log"]

def run_app():
    logger.info("Starting CLI Generator Assistant application")
    try:
        with gr.Blocks(title="CLI Generator Assistant") as app:
            gr.Markdown("# 🤖 Node Generator Agent")
            send_to_db = gr.Checkbox("Send Prompts to Database", value=True, label="Send to DB")
            select_mode = gr.Radio(label="Select Mode", choices=[("Manual", "1"), ("Auto", "2")], value="1")
            model = gr.Dropdown(label="Select a Model", choices=config['models'], value=config['models'][2])
            user_input = gr.Textbox(lines=3, label="Describe your pipeline")
            final_output = gr.Textbox(label="Final CLI Commands")

            btn = gr.Button("Generate Commands")
            log_output = gr.Textbox(lines=10, label="Log", interactive=False)

            btn.click(fn=generate_cli, inputs=[user_input, send_to_db, model, select_mode], outputs=[final_output, log_output])
            
            logger.info("Launching Gradio application")
            app.launch()

    except Exception as e:
        logger.exception(f"Error running application: {str(e)}")
        raise

if __name__ == "__main__":
    logger.info("Initializing application")
    run_app()
