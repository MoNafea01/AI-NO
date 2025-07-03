import ast
import shlex
import json, os
import subprocess
main_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "main.py")
def call_script(command_line):
    args = shlex.split(command_line)
    
    cmd_list = ["python", main_path] + args

    try:
        result = subprocess.run(
            cmd_list,
            capture_output=True,
            text=True,
            check=True,
        )
        # print("Subprocess completed successfully.")

    except subprocess.CalledProcessError as e:
        print("Subprocess failed.")
        print("Return code:", e.returncode)
        print("Output:", e.output)
        print("Error output:", e.stderr)
        return {"error": "Subprocess failed", "details": e.stderr}
    except FileNotFoundError:
        print("File not found. Please check the path to cli/main.py.")
        return {"error": "File not found"}

    try:
        response = json.loads(result.stdout)
    except json.JSONDecodeError:
        try:
            response = ast.literal_eval(result.stdout)
        except Exception:
            response =  result.stdout
    return response

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        clean_args = [arg for arg in sys.argv[1:] if arg.strip() != '']
        response = call_script(*clean_args)
        print("Response:", response)
    else:
        # print("No command provided.")
        pass
    
