import os
import re
import joblib
from io import BytesIO
from ai_operations.models import Node
from django.core.exceptions import ObjectDoesNotExist
from sklearn.datasets import load_iris, load_diabetes, load_digits, make_regression, make_classification


class DataHandler:
    """Handles preprocessing and data extraction."""
    @staticmethod
    def extract_data(data):
        '''Extracts node_data from a dictionary.'''
        return data.get('node_data') if isinstance(data, dict) else data


class DirectoryManager:
    """Handles directory operations."""
    @staticmethod
    def make_dirs(directory):
        try:
            os.makedirs(directory, exist_ok=True)
        except Exception as e:
            print(f"Error creating directory: {e}")


class NodeSaver:
    """Handles saving nodes."""
    
    def __call__(self, payload, path: str = None):
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")
        message = payload.get('message', "Done")
        node_id = payload.get('node_id')
        node_name = payload.get('node_name')
        params = payload.get('params', {})
        node = payload.get('node_data')
        task = payload.get('task', "general")
        node_type = payload.get('node_type', "general")
        
        # save to path
        if path:
            path = f"{path}\\{node_name}_{node_id}.pkl"
            nodes_dir = os.path.dirname(path)
            DirectoryManager.make_dirs(nodes_dir)
            print(f"Node saved to: {path}")
            joblib.dump(node, path)

        # save to database
        buffer = BytesIO()
        joblib.dump(node, buffer)
        buffer.seek(0)
        node_bytes = buffer.read()

        Node.objects.update_or_create(
            node_id=node_id,
            defaults={
                'node_name': node_name,
                'message': message,
                'node_data': node_bytes,
                'params': params,
                'task': task,
                'node_type': node_type,
            }
        )
        return {"message": f"Node {node_name} saved.",
                "node_id": node_id,
                "node_name": "node_saver",
                "params": {},
                "task": "save",
                "node_type": "general"
                }



class NodeLoader:
    """Handles loading nodes."""   
    def __call__(self, node_id=None, path=None):
        if not (node_id or path):
            raise ValueError("Either node_id or path must be provided.")
        
        try:
            if isinstance(path, str):
                try:
                    node_data = joblib.load(path)
                    node_name, node_id = NodeNameHandler.handle_name(path)
                    return self.build_payload(node_data, node_name)
                except Exception as e:
                    raise ValueError(f"Error loading node from path: {e}")
            node_entry = Node.objects.get(node_id=node_id)
            buffer = BytesIO(node_entry.node_data)
            node_name = node_entry.node_name
            return self.build_payload(joblib.load(buffer), node_name)
        except ObjectDoesNotExist:
            raise ValueError(f"Node with node_id {node_id} does not exist.")
        except Exception as e:
            raise ValueError(f"Error loading node: {e}")
    
    def build_payload(self, node_data, name):
        return node_data, {
            "message": f"Node {name} Loaded.",
            "node_name": "node_loader",
            "node_id": id(self),
            "params": {},
            "task": "load",
            "node_type": "general"
        }


class NodeDirectoryManager:
    """Handles node directory paths."""
    def __init__(self, folder_name):
        self.folder_name = folder_name
    @staticmethod
    def get_nodes_dir(folder_name=None):
        folder = "saved"
        if folder_name:
            folder = fr"saved\{folder_name}"
        nodes_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        return os.path.join(nodes_path, folder)


class NodeNameHandler:
    """Handles naming and ID extraction from paths."""
    @staticmethod
    def handle_name(path=None):
        if not path:
            raise ValueError("Path must be provided.")
        name = path.split("\\")[-1].split(".")[0]
        _name = re.sub(r'\d+', '', name)
        _id = re.sub(r'\D', '', name)
        _id = _id if _id else 0
        _name = _name.rsplit("_", 1)[0]
        return _name, int(_id)


class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, node, node_name, **kwargs):
        payload = {
            "message": message,
            "params": NodeAttributeExtractor.get_attributes(node),
            "node_id": id(node),
            "node_name": node_name,
            "node_data": node,
            "task": "custom"
        }
        payload.update(kwargs)
        return payload


class NodeAttributeExtractor:
    """Extracts attributes from a node."""
    @staticmethod
    def get_attributes(node):
        
        attributes = {}
        for attr in dir(node):
            if attr.endswith("_") and not attr.startswith("_"):
                atr = getattr(node, attr)
                if hasattr(atr, "tolist"):
                    attributes[attr] = atr.tolist()
        return attributes
    

DATASETS = {
    "iris" : load_iris,
    "diabetes" : load_diabetes,
    "digits" : load_digits,
    "make_regression" : make_regression,
    "make_classification" : make_classification
}