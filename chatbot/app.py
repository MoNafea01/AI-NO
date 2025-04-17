from __init__ import *

from core.rag_pipeline import run_pipeline, parse_command_list
from core.docs import get_docs
from core.utils import extract_id_message
from cli.call_cli import call_script
import gradio as gr

global cur_iter
cur_iter = 0

global docs
docs = get_docs('2')

def generate_cli(user_input, to_db, model, selected_mode):

    if selected_mode == '1':
        doc1 = get_docs(selected_mode)
        return manual_mode(doc1, user_input, model, to_db)
    
    elif selected_mode == '2':
        return auto_mode(user_input, model, to_db)


def manual_mode(docs, question, model, to_db):
    rag_output = run_pipeline(docs, question, model, selected_mode="1", cur_iter=0)
    rag_output = parse_command_list(rag_output)

    print(f"RAG Output : \n"+str(rag_output))
    out = []
    for i, output in enumerate(rag_output):
        cmd = output
        if to_db:
            cmd = call_script(output)
        out.append(cmd)

        print(f"API Output {i}: \n"+str(cmd))
        print('-'*50)
    return out

def auto_mode(question, model, to_db):
    global cur_iter

    if not to_db:
        return "Auto mode is not supported without DB."
    
    while cur_iter < 10:
        cur_iter += 1
        rag_output= run_pipeline(docs, question, model, selected_mode="2", cur_iter=cur_iter)
        rag_output = rag_output.strip().strip("'").strip('"')
        print(f"RAG Output {cur_iter}: ",rag_output)

        api_response = extract_id_message(call_script(rag_output))
        docs[-1].page_content += '\n' + str(api_response)
        print(f"\nAPI Response {cur_iter}: ",api_response)
        print('-'*50)

    return rag_output

def run_app():
    with gr.Blocks(title="CLI Generator Assistant") as app:
        gr.Markdown("# 🤖 CLI Generator using LangChain & Gemini")
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
        btn.click(fn=generate_cli, inputs=[user_input, send_to_db, model, select_mode],
                outputs=[final_output])
        
        app.launch()

if __name__ == "__main__":

    run_app()
