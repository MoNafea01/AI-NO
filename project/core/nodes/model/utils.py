class ModelAttributeExtractor:
    """Extracts attributes from a model."""
    @staticmethod
    def get_attributes(model):
        fitted_params = {}
        attributes = ['coef_', 'intercept_', 'classes_', 
                      'support_vectors_', 'feature_importances_',
                      'tree_', 'n_iter_']
        for attr in attributes:
            if hasattr(model, attr):
                atr = getattr(model, attr)
                if hasattr(atr, 'tolist'):
                    fitted_params[attr] = atr.tolist()
        return fitted_params

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
        }
        payload.update(kwargs)
        return payload
