import json
import subprocess

def call_script(command, parameters, *args):
    # Format the command string
    command_str = f"{command} {json.dumps(parameters)}"
    # Here, you might call your script. For example:
    try:
        result = subprocess.run(
            ["python", "./cli/main.py", command_str],
            capture_output=True,
            text=True,
            check=True
        )
        print("Subprocess completed successfully.")
        # print(result)
        # print("STDOUT:", result.stdout)
        # print("STDERR:", result.stderr)
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

# Example usage:
model_response = call_script("make model", {
    "model_name": "logistic_regression",
    "model_type": "linear_models",
    "task": "classification"
}, *["aino mode", "selusr admin admin", "selprj 1"])
print("Model created:", model_response)

data_response = call_script("make data_loader", {
    "params":{"dataset_name": "iris"}
})
print("Data loaded:", data_response)
