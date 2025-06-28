from ..utils import ModelAttributeExtractor
import uuid

class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, model, node_name, **kwargs):
        payload = {
            "message": message,
            "params": ModelAttributeExtractor.get_attributes(model),
            "node_id": uuid.uuid1().int & ((1 << 63) - 1),
            "node_name": node_name,
            "node_data": model,
            "children": [],
            "parent": [],
        }
        params = kwargs.get("params", {})
        if isinstance(params, dict):
            kwargs['params'] = [{k: v} for k, v in params.items()]
        payload.update(kwargs)
        return payload
