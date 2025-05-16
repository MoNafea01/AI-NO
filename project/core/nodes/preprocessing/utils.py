from ..utils import PreprocessorAttributeExtractor
import uuid

class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, node_data, node_name, **kwargs):
        payload = {
            "message": message,
            "params": PreprocessorAttributeExtractor.get_attributes(node_data),
            "node_id": uuid.uuid1().int & ((1 << 63) - 1),
            "node_name": node_name,
            "node_data": node_data,
            "task": "custom",
            "children": [],
            "parent": [],
        }
        params = kwargs.get("params", {})
        kwargs['params'] = [{k: v} for k, v in params.items()]
        payload.update(kwargs)
        return payload
