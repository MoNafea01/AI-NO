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
    def __call__(self, node_id: str) :
        """Delete a node by its ID from the database and filesystem."""
        if not node_id:
            raise ValueError("Node ID must be provided.")
        try:
            # Fetch node from database
            node = Node.objects.get(node_id=node_id)
            node_name = node.node_name
            special_case_nodes = ["fitter_transformer"]
            # Delete the associated file from disk
            folder = "models" if node.task in ["regression", "classification", "fit_model"] else ("preprocessors" if node.task in ["preprocessing", "fit_preprocessor"] else "data")
            node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{node_id}.pkl")
            if os.path.exists(node_path):
                os.remove(node_path)
            if node_name in special_case_nodes:
                folder = 'preprocessors'
                id_ = node.node_id
                node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{id_}.pkl")
                if os.path.exists(node_path):
                    os.remove(node_path)
            # Delete the database entry
            node.delete()
            return True, f"Node {node_id} deleted."
            
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            raise e  # Re-raise for the view to handle


class NodeUpdater:
    """Updates a node in the database."""
    def __call__(self, node_id, payload):
        if not node_id:
            raise ValueError("Node ID must be provided.")
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")
        try:
            node = Node.objects.get(node_id=node_id)
            multi_channel_nodes = ["data_loader", "train_test_split", "splitter"]
            special_case_nodes = ["fitter_transformer"]
            folder = "models" if node.task in ["regression", "classification", "fit_model"] else ("preprocessors" if node.task in ["preprocessing", "fit_preprocessor"] else "data")
            node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node.node_name}_{node_id}.pkl")
            folder_path = os.path.dirname(node_path)
            data, _ = NodeLoader()(node_id=payload.get("node_id"))
            payload["node_data"] = data
            old_id = payload.get("node_id")
            if node.node_name in multi_channel_nodes:
                id_ =node.node_id
                id_1, id_2 = id_+1, id_+2
                old_id_1, old_id_2 = old_id+1, old_id+2
                data1, _ = NodeLoader()(old_id_1)
                data2, _ = NodeLoader()(old_id_2)
                payload_1, payload_2 = payload.copy(), payload.copy()
                payload_1['node_id'] = id_1
                payload_2['node_id'] = id_2
                payload_1['node_data'] = data1
                payload_2['node_data'] = data2
                NodeSaver()(payload_1, path=folder_path)
                NodeSaver()(payload_2, path=folder_path)
                NodeDeleter()(old_id_1)
                NodeDeleter()(old_id_2)
            elif node.node_name in special_case_nodes:
                folders = ['preprocessors', 'data']
                payload_ = payload.copy()
                for idx, folder in enumerate(folders,1):
                    id_ = node.node_id
                    folder_path_ = NodeDirectoryManager.get_nodes_dir(folder)
                    old_id_new = old_id+idx
                    data, _ = NodeLoader()(old_id_new)
                    payload_['node_id'] = id_+idx
                    payload_['node_data'] = data
                    NodeSaver()(payload_, path=folder_path_)
                    NodeDeleter()(old_id_new)

            payload['node_id'] = node_id
            NodeSaver()(payload, path=folder_path)
            NodeDeleter()(old_id)
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
    def __call__(self,*args):
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