#chatbot/app.py
from __init__ import *

from core.rag_pipeline import run_pipeline
from core.docs import get_docs
from core.utils import extract_id_message, parse_command_list
from cli.call_cli import call_script
import gradio as gr


def generate_cli(user_input, to_db, model, selected_mode, cur_iter):
    MANUAL = '1'
    AUTO = '2'

    if selected_mode == MANUAL:
        return manual_mode(user_input, model, to_db)
    
    elif selected_mode == AUTO:
        return auto_mode(user_input, model, to_db, cur_iter)

def manual_mode(question, model, to_db):
    docs = get_docs('1')
    rag_output = run_pipeline(docs, question, model, selected_mode="1", cur_iter=0)
    rag_output = parse_command_list(rag_output)

    log = ""
    def log_msg_inner(msg, *args, **kwargs):
        nonlocal log
        print(msg, *args, **kwargs)
        log += msg + "\n"

    log_msg_inner(f"RAG Output : \n" + str(rag_output), end='\n\n')

    out = []
    for i, output in enumerate(rag_output):
        cmd = output
        if to_db:
            cmd = call_script(output)
        out.append(cmd)

        log_msg_inner(f"\nAPI Output {i+1}: \n" + str(cmd), end='\n')

    log_msg_inner('-'*50)

    with open("cli_generator_log.txt", "a", encoding="utf-8") as f:
        f.write(log)
        f.write("\n\n")

    return out, log

def auto_mode(question, model, to_db, cur_iter):
    docs = get_docs('2')
    log = ""

    def log_msg_inner(msg, *args, **kwargs):
        nonlocal log
        print(msg, *args, **kwargs)
        log += msg + "\n"

    if not to_db:
        msg = "Auto mode is not supported without DB."
        log_msg_inner(msg)
        with open("cli_generator_log.txt", "a", encoding="utf-8") as f:
            f.write(log)
            f.write("\n\n")

        return msg, log
    
    while cur_iter < 10:
        cur_iter += 1
        rag_output= run_pipeline(docs, question, model, selected_mode="2", cur_iter=cur_iter)
        rag_output = rag_output.strip().strip("'").strip('"')
        log_msg_inner(f"RAG Output {cur_iter}: \n" + str(rag_output), end='\n\n')

        api_response = extract_id_message(call_script(rag_output))
        docs[-1].page_content += '\n'.join(api_response)
        print("content of last page",docs[-1].page_content)
        log_msg_inner(f"API Response {cur_iter}: " + str(api_response))
        log_msg_inner('-'*50)

    with open("cli_generator_log.txt", "a", encoding="utf-8") as f:
        f.write(log)
        f.write("\n\n")

    return rag_output, log


def run_app():
    with gr.Blocks(title="CLI Generator Assistant") as app:
        gr.Markdown("# 🤖 Node Generator Agent")
        send_to_db = gr.Checkbox("Send Prompts to Database", value=True, label="Send to DB")
        select_mode = gr.Radio(label="Select Mode", choices=[("Manual", "1"), ("Auto", "2")], value="1")
        model = gr.Dropdown(label="Select a Model", choices=[
            ("Gemini 1.5 Pro", "gemini-1.5-pro"), 
            ("Gemini 1.5 Flash ", "gemini-1.5-flash"),
            ("Gemini 2.0 Flash ", "gemini-2.0-flash"),
            ], value="gemini-2.0-flash")
        user_input = gr.Textbox(lines=3, label="Describe your pipeline")
        final_output = gr.Textbox(label="Final CLI Commands")

        btn = gr.Button("Generate Commands")
        log_output = gr.Textbox(lines=10, label="Log", interactive=False)

        cur_iter_state = gr.State(value=0)
        btn.click(fn=generate_cli, inputs=[user_input, send_to_db, model, select_mode, cur_iter_state], outputs=[final_output, log_output])
        
        app.launch()

if __name__ == "__main__":

    run_app()
