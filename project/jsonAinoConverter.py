import json
import sys
import base64

class AinoprjConverter:
    types = {
        "node_id": "int", "node_name": "str", "node_type": "str", 
        "task": "str", "message": "str", "node_data": "str",
        "params": "dict", "x_loc": "int", "y_loc": "int",
        "input_nodes": "list", "output_nodes": "list"
    }

    def __init__(self, in_format, out_format, source_path, destination_path, encrypt):
        self.in_format = in_format
        self.out_format = out_format
        self.source_path = source_path
        self.destination_path = destination_path
        self.encrypt = encrypt

    def encrypt_data(self, data):
        return base64.b64encode(data.encode()).decode() if self.encrypt else data

    def decrypt_data(self, encrypted_data):
        return base64.b64decode(encrypted_data).decode() if self.encrypt else encrypted_data

    def json_to_ainoprj(self):
        try:
            with open(self.source_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            ainoprj_data = "AINOPRJ_START\n"
            for node in data:
                ainoprj_data += "\tNODE_START\n"
                for key, value in node.items():
                    type_value = self.types.get(key, "na")
                    ainoprj_data += f"\t\t{key}={value}={type_value}\n"
                ainoprj_data += "\tNODE_END\n"
            ainoprj_data += "AINOPRJ_END"
            
            encrypted_data = self.encrypt_data(ainoprj_data)
            with open(self.destination_path, 'w', encoding='utf-8') as f:
                f.write(encrypted_data)
            
            print("Conversion successful: JSON to AINOPRJ")
        except Exception as e:
            print(f"Error: {e}")

    def ainoprj_to_json(self):
        try:
            with open(self.source_path, 'r', encoding='utf-8') as f:
                encrypted_data = f.read()
                if len(encrypted_data.split('\n')) == 1:
                    self.encrypt = True
                decrypted_data = self.decrypt_data(encrypted_data)
            nodes = []
            
            for line in decrypted_data.split('\n'):
                line = line.lstrip()
                if line in ["AINOPRJ_START", "AINOPRJ_END"]:
                    continue
                elif line == "NODE_START":
                    current_node = {}
                elif line == "NODE_END":
                    nodes.append(current_node)
                    current_node = None
                else:
                    try:
                        key, rest = line.split('=', 1)
                        value, type_string = rest.rsplit('=', 1)
                        current_node[key] = value if type_string == "str" else eval(value)
                    except ValueError as ve:
                        print(f"Skipping malformed line: {key} | Error: {ve}")
            
            with open(self.destination_path, 'w', encoding='utf-8') as f:
                json.dump(nodes, f, indent=4)
            
            print("Conversion successful: AINOPRJ to JSON")
        except Exception as e:
            print(f"Error: {e}")

    def convert(self):
        if self.in_format == self.out_format:
            print("Error: Input and output formats must be different.")
            sys.exit(1)
        
        if self.in_format == "json" and self.out_format == "ainoprj":
            self.json_to_ainoprj()
        elif self.in_format == "ainoprj" and self.out_format == "json":
            self.ainoprj_to_json()
        else:
            print("Error: Invalid conversion type.")
            sys.exit(1)


def main():
    if len(sys.argv) != 6:
        print("Usage: python json_ainoprj_converter.py <in_format> <out_format> <source_path> <destination_path> <encrypt_enabled>")
        sys.exit(1)
    
    in_format, out_format, source_path, destination_path, encrypt_enabled = sys.argv[1:]
    
    if in_format not in ["json", "ainoprj"] or out_format not in ["json", "ainoprj"]:
        print("Error: Formats must be 'json' or 'ainoprj'.")
        sys.exit(1)
    
    encrypt = encrypt_enabled.lower() == "true"
    converter = AinoprjConverter(in_format, out_format, source_path, destination_path, encrypt)
    converter.convert()

if __name__ == "__main__":
    main()
