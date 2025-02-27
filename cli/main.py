from cmd_handler import cmd_handler
from save_load import load_data_from_file, save_data_to_file
import os

def main():
    print("Welcome to Aino CMD Interface!")
    # Load data
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data_store.json')
    load_data_from_file(path)
    mode = False
    while True:
        try:
            user_input = input(">> ").strip()
            if user_input.lower() in {"exit", "quit"}:
                print("Exiting Aino CMD Interface. Goodbye!")
                save_data_to_file(path)
                break
            if len(user_input.split()) > 1:
                if user_input.split()[1].lower() == "mode":
                    mode = True
            if len(user_input.split()) == 1:
                if user_input.split()[0].lower() == "nomode":
                    mode = False
            result = cmd_handler(user_input,mode)
            if result:
                print(result)
        except KeyboardInterrupt:
            print("\nExiting Aino CMD Interface. Goodbye!")
            save_data_to_file(path)
            break
        except Exception as e:
            print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()
