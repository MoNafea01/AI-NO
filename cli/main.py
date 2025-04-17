from cmd_handler import cmd_handler
from save_load import load_data_from_file
import json
from __init__ import *

def main(*args):
    # Load data
    load_data_from_file(os.path.join(cli_path, 'data_store.json'))
    
    if len(sys.argv) > 1:        # Process command-line arguments
        command_str = " ".join(sys.argv[1:])
        mode = True
        
        cmd_handler("recent" ,mode)
        result = cmd_handler(command_str, mode)
        # Print result as JSON
        response = json.dumps(result)
        print(response)     # DON'T REMOVE this line as it's used with a subprocess
        if result:
            file_path = chatbot_path + "/logs.txt"
            with open(file_path, "a") as f:
                f.write(response)
                f.write('\n')
        
        if result == "Exiting Aino CMD Interface. Goodbye!":
            return
    else:
        # Interactive mode
        print("Welcome to Aino CMD Interface!")
        mode = False
        while True:
            try:
                user_input = input(">> ").strip()
                inputs_list = user_input.split()
                if len(inputs_list) > 1:
                    if inputs_list[1].lower() == "mode":
                        mode = True
                if len(inputs_list) == 1:
                    if inputs_list[0].lower() == "nomode":
                        mode = False
                result = cmd_handler(user_input, mode)
                if result:
                    print(result)
                if result == "Exiting Aino CMD Interface. Goodbye!":
                    break
            except KeyboardInterrupt:
                from cmd_handler import exit_aino
                print(exit_aino())
                break
            except Exception as e:
                print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()
