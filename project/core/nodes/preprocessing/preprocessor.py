from ..configs.preprocessors import PREPROCESSORS as preprocessors
from .utils import PayloadBuilder
from ..utils import NodeNameHandler
from ...repositories.node_repository import NodeSaver, NodeLoader

class Preprocessor:
    """Handles preprocessors creation and parameter management."""
    def __init__(self, preprocessor_name, preprocessor_type, params=None, preprocessor_path=None):
        self.preprocessor_name = preprocessor_name
        self.preprocessor_type = preprocessor_type
        self.task = "preprocessing"
        self.preprocessor_path = preprocessor_path
        self.params = params if params else self._get_default_params()
        self.payload = self.create_preprocessor()

    def _get_default_params(self):
        try:
            return preprocessors.get(self.preprocessor_type, {}).get(self.preprocessor_name, {}).get('params', {})
        except AttributeError:
            raise ValueError(f"Invalid configuration for preprocessor type: {self.preprocessor_type}, task: {self.task}, preprocessor name: {self.preprocessor_name}.")

    def create_preprocessor(self):
        if self.preprocessor_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()
        
    def _create_from_dict(self):
        try:
            if self.preprocessor_type not in preprocessors:
                raise ValueError(f"Unsupported preprocessor type: {self.preprocessor_type}. Available types are: {list(preprocessors.keys())}.")
            
            if self.preprocessor_name not in preprocessors[self.preprocessor_type]:
                raise ValueError(f"Unsupported preprocessor name: {self.preprocessor_name} for task: {self.task}.")
            
            preprocessor_node = preprocessors[self.preprocessor_type][self.preprocessor_name]['node']
            preprocessor = preprocessor_node(**self.params)
            return self._create_handler(preprocessor, self.preprocessor_name, self.preprocessor_type, self.task)
        
        except Exception as e:
            raise ValueError(f"Error creating preprocessor from json: {e}")
        
    def _create_from_path(self):
        try:
            preprocessor = NodeLoader()(path=self.preprocessor_path).get('node_data')
            preprocessor_name, _ = NodeNameHandler.handle_name(self.preprocessor_path)
            preprocessor_type = self.find_preprocessor_type(preprocessor_name, preprocessors)
            return self._create_handler(preprocessor, preprocessor_name, preprocessor_type, "preprocessing")
        except Exception as e:
            raise ValueError(f"Error loading preprocessor from path: {e}")
    
    def _create_handler(self, preprocessor, preprocessor_name=None, preprocessor_type=None, task=None):
        try:
            payload = PayloadBuilder.build_payload(f"Preprocessor created: {preprocessor_name}", preprocessor, preprocessor_name, 
                                                   node_type=preprocessor_type,task=task)
            
            NodeSaver()(payload, path=f"core\\nodes\\saved\\preprocessors")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error creating preprocessor: {e}")
    
    def find_preprocessor_type(self, preprocessor_name, preprocessors):
        
        for preprocessor_type in preprocessors:
                if preprocessor_name in preprocessors.get(preprocessor_type):
                    return preprocessor_type
        return "general"
    
    def update_params(self, params):
        self.params = params
        self.payload = self.create_preprocessor()

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(return_serialized=True)(self.payload.get("node_id")).get('node_data')
            self.payload.update({"node_data": node_data})
        return self.payload

if __name__ == "__main__":
    preprocessor_args = {
        "preprocessor_name": "standard_scaler",
        "preprocessor_type": "scaler",
        "params": {}
    }
    
    scaler = Preprocessor(**preprocessor_args)
    print(scaler)
    
