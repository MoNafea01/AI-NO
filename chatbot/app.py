from __init__ import *

from core.rag_pipeline import run_pipeline
from core.utils import extract_keywords_hybrid, parse_command_list, args_extractor, replace_args
from cli.call_cli import call_script
import gradio as gr

def generate_cli(user_input, to_db, model):
    rag_output, _, ref_keywords, mapping, data_mapping = run_pipeline(user_input, model)
    parsed_output = parse_command_list(rag_output)
    extracted_names = extract_keywords_hybrid(user_input, ref_keywords, len(parsed_output))
    extracted_args = args_extractor(extracted_names, mapping, data_mapping)
    command_list = replace_args(parsed_output, extracted_args, extracted_names, mapping)
    out = []
    for command in command_list:
        cmd = command
        if to_db:
            cmd = call_script(command)

        out.append(cmd)
    return out


def run_app():
    with gr.Blocks(title="CLI Generator Assistant") as app:
        gr.Markdown("# 🤖 CLI Generator using LangChain & Gemini")
        send_to_db = gr.Checkbox("Send Prompts to Database", value=True, label="Send to DB")
        model = gr.Dropdown(label="Select a Model", choices=[("Gemini Pro", "gemini-1.5-pro"), ("Gemini Flash", "gemini-1.5-flash")], value="gemini-1.5-flash")
        user_input = gr.Textbox(lines=3, label="Describe your pipeline")
        final_output = gr.Textbox(label="Final CLI Commands")

        btn = gr.Button("Generate Commands")
        btn.click(fn=generate_cli, inputs=[user_input, send_to_db, model],
                outputs=[final_output])
        
        app.launch()

if __name__ == "__main__":

    run_app()
