import os, re
from ai_operations.models import Node
from core.nodes.configs.const_ import (
    MODELS_TASKS, PREPROCESSORS_TASKS, LAYERS, DATA_NODES, SAVING_DIR)


class DirectoryManager:
    """Handles directory operations."""
    @staticmethod
    def make_dirs(directory):
        try:
            os.makedirs(directory, exist_ok=True)
        except Exception as e:
            print(f"Error creating directory: {e}")


class NodeDirectoryManager:
    """Handles node directory paths."""
    @staticmethod
    def get_nodes_dir():
        folder = SAVING_DIR
        file_path = os.path.abspath(__file__)
        nodes_path = os.path.dirname(file_path)
        core_path = os.path.dirname(nodes_path)
        project_path = os.path.dirname(core_path)
        saving_path = os.path.join(project_path, folder)
        if os.path.exists(saving_path):
            return saving_path
        DirectoryManager.make_dirs(saving_path)
        return saving_path


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
    def build_payload(message, node_data, node_name, **kwargs):
        payload = {
            "message": message,
            "params": NodeAttributeExtractor.get_attributes(node_data),
            "node_id": id(node_data),
            "node_name": node_name,
            "node_data": node_data,
            "task": "custom",
            "children": [],
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

def delete_node(node: Node):
    node_path = node.node_data
    if os.path.exists(node_path):
        os.remove(node_path)
    node.delete()

def get_folder_by_task(task):
    return "model" if task in MODELS_TASKS else (
        "preprocessoring" if task in PREPROCESSORS_TASKS else (
            "nets" if task in LAYERS else (
                "other" if task in DATA_NODES else "other"
                )
            )
        )
