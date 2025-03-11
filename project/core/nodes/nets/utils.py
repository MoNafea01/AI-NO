class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, nn, node_name, **kwargs):
        payload = {
            "message": message,
            "params": {},
            "node_id": id(nn),
            "node_name": node_name,
            "node_data": nn,
            "task":"neural_network",
            "children": [],
            "node_type": "nn_layer"
        }
        payload.update(kwargs)
        return payload