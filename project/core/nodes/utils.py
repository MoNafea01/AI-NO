import os
import re
import joblib
from io import BytesIO
from ai_operations.models import Node, Component
from django.core.exceptions import ObjectDoesNotExist
from sklearn.datasets import load_iris, load_diabetes, load_digits, make_regression, make_classification
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, mean_squared_error, mean_absolute_error, r2_score

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
                "node_type": "saver"
                }


class NodeLoader:
    """Handles loading nodes."""   
    def __call__(self, node_id=None, path=None) -> tuple[bytearray, dict]:
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
            "task": "load_node",
            "node_type": "loader"
        }


class NodeDeleter:
    def __call__(self, node_id: str, is_special_case=False, is_multi_channel=False, from_view=False):
        """Delete a node by its ID from the database and filesystem."""
        if not node_id:
            raise ValueError("Node ID must be provided.")
        node_id = int(node_id) if node_id else None
        try:
            
            # Fetch node from database
            node = Node.objects.get(node_id=node_id)
            node_name = node.node_name
            # Delete the associated file from disk
            folder = "models" if node.task in ["regression", "classification", "fit_model"] else (
                "preprocessors" if node.task in ["preprocessing", "fit_preprocessor", "fit_transform"] else "data")
            node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{node_id}.pkl")
            if os.path.exists(node_path):
                os.remove(node_path)
            
            folders = None
            if is_multi_channel:
                folders = ['data', 'data']
            elif is_special_case:
                folders = ['preprocessors', 'data']

            if folders:
                for folder in folders:
                    for i in range(1,3):
                        node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{node_id + i}.pkl")
                        if os.path.exists(node_path):
                            os.remove(node_path)
            # Delete the database entry
            node.delete()

            if from_view:
                for i in range(1,3):
                    node = Node.objects.filter(node_id=node_id + i)
                    if node.exists():
                        node.delete()

            return True, f"Node {node_id} deleted."
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            raise e  # Re-raise for the view to handle


class NodeUpdater:
    """Updates a node in the database."""
    def __call__(self, node_id, payload):
        from .config import setup_config
        if not node_id:
            raise ValueError("Node ID must be provided.")
        node_id = int(node_id) if node_id else None
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")
        
        try:
            is_multi_channel = False
            is_special_case = False
            node = Node.objects.get(node_id=node_id)
            multi_channel_nodes = ["data_loader", "train_test_split", "splitter"]
            special_case_nodes = ["fitter_transformer"]

            new_task = payload.get('task', node.task)
            folder = "models" if new_task in ["regression", "classification", "fit_model"] else (
                "preprocessors" if new_task in ["preprocessing", "fit_preprocessor", "fit_transform"] else "data")
            
            folder_path = NodeDirectoryManager.get_nodes_dir(folder)
            original_id = payload.get("node_id")
            payload['node_data'] = []

            folders = None
            if node.node_name in multi_channel_nodes:
                is_multi_channel = True
                folders = ['data', 'data']
            elif node.node_name in special_case_nodes:
                is_special_case = True
                folders = ['preprocessors', 'data']
            
            if folders:
                for i, f in enumerate(folders, 1):
                    config = setup_config(node.node_name, str(i))
                    f_path = NodeDirectoryManager.get_nodes_dir(f)
                    tmp_id = original_id + i
                    new_id = node_id + i
                    data, _ = NodeLoader()(tmp_id)
                    new_payload = payload.copy()
                    new_payload['node_id'] = new_id
                    new_payload['node_data'] = data
                    new_payload.update(**config)
                    payload['node_data'].append(data)
                    NodeSaver()(new_payload, path=f_path)
                    NodeDeleter()(tmp_id)

            payload['node_id'] = node_id
            NodeSaver()(payload, path=folder_path)
            NodeDeleter()(original_id, is_special_case, is_multi_channel)
            if node.node_name != payload.get("node_name"):

                node_path = os.path.join(folder_path, f"{node.node_name}_{node_id}.pkl")
                if os.path.exists(node_path):
                    os.remove(node_path)
            
            return True, f"Node {node_id} updated."
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            return False, f"Error updating node: {e}"

class ClearAllNodes:
    """Clears all nodes from the database and filesystem."""
    def __call__(self, *args):
        try:
            for arg in args:
                if arg == 'components':
                    Component.objects.all().delete()
                    return True, "All components cleared."
                
            # deletes all objects in the Node model
            Node.objects.all().delete()
            nodes_dir = NodeDirectoryManager.get_nodes_dir()

            for folder in os.listdir(nodes_dir):
                folder_path = os.path.join(nodes_dir, folder)
                for file in os.listdir(folder_path):
                    file_path = os.path.join(folder_path, file)
                    if os.path.isfile(file_path):
                        os.remove(file_path)

            return True, "All nodes cleared."
        except Exception as e:
            return False, f"Error clearing nodes: {e}"


class NodeDirectoryManager:
    """Handles node directory paths."""
    def __init__(self, folder_name):
        self.folder_name = folder_name

    @staticmethod
    def get_nodes_dir(folder_name=None):
        folder = "nodes\\saved"
        if folder_name:
            folder = fr"nodes\saved\{folder_name}"
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

METRICS = {
    "accuracy" : accuracy_score,
    "precision" : precision_score,
    "recall" : recall_score,
    "f1" : f1_score,
    "mse" : mean_squared_error,
    "mae" : mean_absolute_error,
    "r2" : r2_score
}