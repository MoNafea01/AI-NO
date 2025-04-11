import os, re
from ai_operations.models import Node
from core.nodes.configs.const_ import (
    MODELS_TASKS, PREPROCESSORS_TASKS, NN_TASKS, DATA_HANDLER_TASKS, NN_NAMES, MODELS_NAMES, PREPROCESSORS_NAMES, DATA_HANDLER_NAMES)


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



class FolderHandler:
    """Handles folder assignment based on task or node name."""
    @staticmethod
    def get_folder_by_task(task):
        return "model" if task in MODELS_TASKS else (
            "preprocessoring" if task in PREPROCESSORS_TASKS else (
                "nets" if task in NN_TASKS else (
                    "other" if task in DATA_HANDLER_TASKS else "other"
                    )
                )
            )

    @staticmethod
    def get_folder_by_node_name(node_name):
        return "model" if node_name in MODELS_NAMES else (
            "preprocessoring" if node_name in PREPROCESSORS_NAMES else (
                "nets" if node_name in NN_NAMES else (
                    "other" if node_name in DATA_HANDLER_NAMES else "other"
                    )
                )
            )


def delete_node(node: Node):
    node_path = node.node_data
    if os.path.exists(node_path):
        os.remove(node_path)
    node.delete()

