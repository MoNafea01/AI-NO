import sys, os, json
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

cli_path = os.path.dirname(os.path.abspath(__file__))
chatbot_path = os.path.join(os.path.dirname(cli_path), 'chatbot')
