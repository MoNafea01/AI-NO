from ..utils import ModelAttributeExtractor

class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, model, node_name, **kwargs):
        payload = {
            "message": message,
            "params": ModelAttributeExtractor.get_attributes(model),
            "node_id": id(model),
            "node_name": node_name,
            "node_data": model,
            "children": [],
            "parent": [],
        }
        params = kwargs.get("params", {})
        kwargs['params'] = [{k: v} for k, v in params.items()]
        payload.update(kwargs)
        return payload
