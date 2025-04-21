#chatbot/core/templates.py
import os

parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
template_dir = os.path.join(parent_dir, 'templates')


def get_template(mode):
    file_map = {
        '1': 'manual_template.txt',
        '2': 'auto_template.txt'
    }
    template_path = os.path.join(template_dir, file_map[mode])
    if not os.path.exists(template_path):
        raise FileNotFoundError(f"Template file for mode {mode} not found.")

    with open(template_path, 'r') as file:
        template = file.read()
    return template
