#chatbot/app.py
import gradio as gr
from __init__ import *
from chatbot.core.utils import init_logger, load_config
from chatbot.utils import process_query


# Configure logging
parent_path = os.path.dirname(os.path.abspath(__file__))
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

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
