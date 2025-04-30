import json, os
import subprocess
main_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "main.py")
def call_script(command, *args, **kwargs):

    # Here, you might call your script. For example:
    try:
        result = subprocess.run(
            ["python", main_path, command],
            capture_output=True,
            text=True,
            check=True,
        )
        print("Subprocess completed successfully.")

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
        response = {"error": "Failed to decode JSON", "raw": result.stdout}
    return response

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        command = sys.argv[1]
        try:
            parameters = sys.argv[2]
        except:
            parameters = ""
        
        args = ""
        if len(sys.argv) > 3:
            args = sys.argv[3:]
        # print(command, parameters, args)
        response = call_script(command, parameters, args)
        print("Response:", response)
    else:
        print("No command provided.")
