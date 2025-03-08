import os, re


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
    def build_payload(message, node_data, node_name, **kwargs):
        payload = {
            "message": message,
            "params": NodeAttributeExtractor.get_attributes(node_data),
            "node_id": id(node_data),
            "node_name": node_name,
            "node_data": node_data,
            "task": "custom",
            "children": {},
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
