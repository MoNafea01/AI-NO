import os, sys
import warnings
os.environ['GOOGLE_API_KEY'] = "AIz..."

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
warnings.filterwarnings('ignore', category=DeprecationWarning)

import gradio as gr

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.rag_pipeline import run_pipeline
from core.utils import extract_keywords_hybrid, parse_command_list, args_extractor, replace_args
from cli.call_cli import call_script

def generate_cli(user_input, to_db):
    rag_output, query, ref_keywords, mapping, data_mapping = run_pipeline(user_input)
    extracted_names = extract_keywords_hybrid(user_input, ref_keywords)
    parsed_output = parse_command_list(rag_output)
    extracted_args = args_extractor(extracted_names, mapping, data_mapping)
    command_list = replace_args(parsed_output, extracted_args)
    out = []
    if to_db:
        for command in command_list:
            args = command.split(' ')[-1]
            command = ' '.join(command.split(' ')[:-1])
            script_output = call_script(command, args)
            if isinstance(script_output, dict):
                out.append(script_output)
            else:
                out.append({"error": "Failed to decode JSON", "raw": script_output})

    
    return out
    

with gr.Blocks(title="CLI Generator Assistant") as demo:
    gr.Markdown("# 🤖 CLI Generator using LangChain & Gemini")
    send_to_db = gr.Checkbox("Send Prompts to Database", value=True)
    user_input = gr.Textbox(lines=3, label="Describe your pipeline")
    final_output = gr.Textbox(label="Final CLI Commands")

    btn = gr.Button("Generate Commands")
    btn.click(fn=generate_cli, inputs=[user_input, send_to_db],
              outputs=[final_output])

demo.launch()
