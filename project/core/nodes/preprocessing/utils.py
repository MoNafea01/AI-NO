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
        if isinstance(params, dict):
            kwargs['params'] = [{"name":k, "default": v, "type": v.__class__.__name__} for k, v in params.items()]
        payload.update(kwargs)
        return payload
