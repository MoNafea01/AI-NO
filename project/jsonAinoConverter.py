import json
import sys
import base64
import hashlib
import os
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

class AinoprjConverter:
    types = {
        "node_id": "int", 
        "displayed_name": "str",
        "node_name": "str",
        "message": "str", 
        "params": "dict", 
        "task": "str", 
        "node_type": "str", 
        "uid": "int",
        "parent":"list", 
        "children": "list", 
        "location_x": "int",
        "location_y": "int", 
        "input_ports": "list", 
        "output_ports": "list",
        "project": "int", 
        "node_data": "str",
        "created_at": "str", 
        "updated_at": "str",
    }

    def __init__(self, in_format, out_format, source_path, destination_path, encrypt, password=None):
        self.in_format = in_format
        self.out_format = out_format
        self.source_path = source_path
        self.destination_path = destination_path
        self.encrypt = encrypt
        self.password = password
        self.SECRET_KEY = self.get_secret_key()

    def get_secret_key(self):
        """Retrieve the encryption key from an environment variable."""
        if self.password:
            os.environ["AESC_KEY"] = self.password
        else:
            os.environ["AESC_KEY"] = "aino_secret_key"

        key = os.getenv("AESC_KEY")
        if not key:
            raise ValueError("Encryption key not set! Use: export AESC_KEY='your_key'")
        return hashlib.sha256(key.encode()).digest()[:16]  # Derive 16-byte key from SHA-256 hash

    def encrypt_data(self, data):
        if not self.encrypt:
            return data
        cipher = AES.new(self.SECRET_KEY, AES.MODE_CBC, iv=self.SECRET_KEY)  # Using key as IV (for simplicity)
        encrypted_bytes = cipher.encrypt(pad(data.encode(), AES.block_size))
        return base64.b64encode(encrypted_bytes).decode()

    def decrypt_data(self, encrypted_data):
        if not self.encrypt:
            return encrypted_data
        cipher = AES.new(self.SECRET_KEY, AES.MODE_CBC, iv=self.SECRET_KEY)
        decrypted_bytes = unpad(cipher.decrypt(base64.b64decode(encrypted_data)), AES.block_size)
        return decrypted_bytes.decode()

    def json_to_ainoprj(self):
        try:
            with open(self.source_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            ainoprj_data = "AINOPRJ_START\n"
            if isinstance(data, dict):
                if "nodes" in data:
                    data = data["nodes"]
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
            
            print("Conversion successful: JSON to AINOPRJ (Encrypted)")
        except Exception as e:
            print(f"Error: {e}")

    def ainoprj_to_json(self):
        self.encrypt = False
        try:
            with open(self.source_path, 'r', encoding='utf-8') as f:
                encrypted_data = f.read()
                if len(encrypted_data.split('\n')) == 1:
                    self.encrypt = True  # If data is a single line, assume it's encrypted
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
            
            print("Conversion successful: AINOPRJ to JSON (Decrypted)")
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



def main(*args):
    if not (6 <= len(sys.argv) <=7) :
        print("Usage: python json_ainoprj_converter.py <in_format> <out_format> <source_path> <destination_path> <encrypt_enabled> <password[optional]>")
    elif not (5 <= len(args) <= 6) :
        print("Error: Incorrect number of arguments.")
        sys.exit(1)
    
    password = None
    if len(sys.argv) == 6:
        in_format, out_format, source_path, destination_path, encrypt_enabled = sys.argv[1:]
    elif len(sys.argv) == 7:
        in_format, out_format, source_path, destination_path, encrypt_enabled, password = sys.argv[1:]

    elif len(args) == 5:
        in_format, out_format, source_path, destination_path, encrypt_enabled = args
    elif len(args) == 6:
        in_format, out_format, source_path, destination_path, encrypt_enabled, password = args
    else:
        print("Error: Incorrect number of arguments.")
        sys.exit(1)
    
    if in_format not in ["json", "ainoprj"] or out_format not in ["json", "ainoprj"]:
        print("Error: Formats must be 'json' or 'ainoprj'.")
        sys.exit(1)
    
    encrypt = encrypt_enabled.lower() in ["true", "yes", "True", "Yes", "1"]
    converter = AinoprjConverter(in_format, out_format, source_path, destination_path, encrypt, password)
    converter.convert()

if __name__ == "__main__":
    main(
        'ainoprj', 
        'json', 
        'C:/Users/a1mme/OneDrive/Desktop/MO/test_grad/project/data.ainoprj', 
        'C:/Users/a1mme/OneDrive/Desktop/MO/test_grad/project/data.json', 
        'True',
        'aino_secret_key')

