import os, sys

cb_dir_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "chatbot")
cli_dir_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "cli")
sys.path.append(cb_dir_path)
sys.path.append(cli_dir_path)