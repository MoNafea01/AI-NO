from ..utils import PreprocessorAttributeExtractor


class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, node_data, node_name, **kwargs):
        payload = {
            "message": message,
            "params": PreprocessorAttributeExtractor.get_attributes(node_data),
            "node_id": id(node_data),
            "node_name": node_name,
            "node_data": node_data,
            "task": "custom",
            "children": [],
        }
        payload.update(kwargs)
        return payload
