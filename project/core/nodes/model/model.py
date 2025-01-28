# Model training nodes
# core/nodes/models.py

from .models import MODELS as models
from .utils import PayloadBuilder
from ..utils import NodeSaver, NodeLoader, NodeNameHandler


class Model:
    """Handles model creation and parameter management."""
    def __init__(self, model_name, model_type, task, params=None, model_path=None):
        self.model_name = model_name
        self.model_type = model_type
        self.task = task
        self.model_path = model_path
        self.params = params if params else self._get_default_params()
        self.payload = self._create_model()

    def _get_default_params(self):
        try:
            return models.get(self.model_type, {}).get(self.task, {}).get(self.model_name, {}).get('params', {})
        except AttributeError:
            raise ValueError(f"Invalid configuration for model type: {self.model_type}, task: {self.task}, model name: {self.model_name}.")

    def _create_model(self):
        if self.model_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()
    
    def _create_from_dict(self):
        try:
            if self.model_type not in models:
                raise ValueError(f"Unsupported model type: {self.model_type}. Available types are: {list(models.keys())}.")
            
            if self.task not in models[self.model_type]:
                raise ValueError(f"Unsupported task type: {self.task} for model type: {self.model_type}.")
            
            if self.model_name not in models[self.model_type][self.task]:
                raise ValueError(f"Unsupported model name: {self.model_name} for task: {self.task}.")

            model_node = models[self.model_type][self.task][self.model_name]['node']
            model = model_node(**self.params)
            return self._create_handler(model, self.model_name, self.model_type, self.task)
        
        except Exception as e:
            raise ValueError(f"Error creating model from json: {e}")
        
    def _create_from_path(self):
        try:
            model = NodeLoader.load(path=self.model_path)
            model_name, _ = NodeNameHandler.handle_name(self.model_path)
            model_type, task = self.find_model_type_and_task(model_name,models)
            return self._create_handler(model, model_name, model_type, task)
        except Exception as e:
            raise ValueError(f"Error loading model from path: {e}")
    
    def _create_handler(self, model, model_name=None, model_type=None, task=None):
        try:
            payload = PayloadBuilder.build_payload(f"Model created: {model_name}", 
                                                    model, model_name, 
                                                    node_type=model_type, 
                                                    task=task)
            NodeSaver.save(payload, path=f"core\\nodes\\saved\\models")
            del payload['node_data']  # Remove the actual node object from the payload
            return payload
        except Exception as e:
            raise ValueError(f"Error creating model: {e}")


    def find_model_type_and_task(self, model_name, models):
        for model_type in models:
            for task in models.get(model_type):
                if model_name in models.get(model_type).get(task):
                    return model_type, task
        return "general", "general"
    
    def update_params(self, params):
        self.params = params
        self.payload = self._create_model()

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        return self.payload





if __name__ == '__main__':
    args = {
        "model_name": "ridge",
        "model_type": "linear_models",
        "task": "regression",
        "params": {
            "alpha": 0.1,
            "fit_intercept": True,
            "normalize": False,
            "copy_X": True,
            "max_iter": None,
            "tol": 0.001,
            "solver": "auto",
            "random_state": None
        }
    }
    model = Model(**args)
    print(model)
