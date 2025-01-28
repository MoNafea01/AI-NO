
from .preprocessors import PREPROCESSORS as preprocessors
from ..utils import NodeSaver

class Preprocessor:
    """Handles preprocessors creation and parameter management."""
    def __init__(self, preprocessor_name, preprocessor_type, params=None):
        self.preprocessor_name = preprocessor_name
        self.preprocessor_type = preprocessor_type
        self.task = "preprocessing"
        self.params = params if params else self._get_default_params()
        self.payload = self.create_preprocessor()

    def _get_default_params(self):
        try:
            return preprocessors.get(self.preprocessor_type, {}).get(self.preprocessor_name, {}).get('params', {})
        except AttributeError:
            raise ValueError(f"Invalid configuration for preprocessor type: {self.preprocessor_type}, task: {self.task}, preprocessor name: {self.preprocessor_name}.")

    def create_preprocessor(self):

        if self.preprocessor_type not in preprocessors:
            raise ValueError(f"Unsupported preprocessor type: {self.preprocessor_type}. Available types are: {list(preprocessors.keys())}.")

        if self.preprocessor_name not in preprocessors[self.preprocessor_type]:
            raise ValueError(f"Unsupported preprocessor name: {self.preprocessor_name} for task: {self.task}.")

        model_node = preprocessors[self.preprocessor_type][self.preprocessor_name]['node']
        model = model_node(**self.params)

        payload = {
            "message": f"Preprocessor created: {self.preprocessor_name}",
            "params": self.params,
            "node_name": self.preprocessor_name,
            "node_type": self.preprocessor_type,
            "task": self.task,
            "node_id": id(model),
            "node_data": model
        }

        NodeSaver.save(payload, path=f"core\\nodes\\saved\\preprocessors")
        del payload['node_data']  # Remove the actual node object from the payload
        return payload

    def update_params(self, params):
        self.params = params
        self.payload = self.create_preprocessor()

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        return self.payload

if __name__ == "__main__":
    preprocessor_args = {
        "preprocessor_name": "standard_scaler",
        "preprocessor_type": "scaler",
        "params": {}
    }
    
    scaler = Preprocessor(**preprocessor_args)
    print(scaler)
    
