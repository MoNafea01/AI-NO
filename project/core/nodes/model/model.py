from ..configs.models import MODELS as models
from .utils import PayloadBuilder
from ..utils import NodeNameHandler
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from sklearn.base import BaseEstimator


class Model:
    """Handles model creation and parameter management."""
    def __init__(self, model_name: str, model_type: str, task: str, 
                 params: dict = None, model_path: str = None) -> dict:
        '''Initializes the Model object.'''

        self.model_name = model_name
        self.model_type = model_type
        self.task = task
        self.model_path = model_path
        default_params = self._get_default_params()
        default_params.update(params) if params else {}
        self.params = default_params
        self.payload = self._create_model()

    def _get_default_params(self) -> BaseEstimator:
        '''Returns the default parameters for the model.'''
        try:
            return models.get(self.model_type, {}).get(self.task, {}).get(self.model_name, {}).get('params', {})
        except AttributeError:
            raise ValueError(f"Invalid configuration for model type: {self.model_type}, task: {self.task}, model name: {self.model_name}.")

    def _create_model(self) -> dict:
        '''Creates the model payload.'''
        if self.model_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()
    
    def _create_from_dict(self) -> dict:
        '''Creates the model payload using json provided.'''
        try:
            # check the informtion provided in the json
            if self.model_type not in models:
                raise ValueError(f"Unsupported model type: {self.model_type}. Available types are: {list(models.keys())}.")
            if self.task not in models[self.model_type]:
                raise ValueError(f"Unsupported task type: {self.task} for model type: {self.model_type}.")
            if self.model_name not in models[self.model_type][self.task]:
                raise ValueError(f"Unsupported model name: {self.model_name} for task: {self.task}.")

            # create the model instance (sklearn)
            model_node = models[self.model_type][self.task][self.model_name]['node']
            model = model_node(**self.params)

            # create the payload
            return self._create_handler(model, self.model_name, self.model_type, self.task)
        except Exception as e:
            raise ValueError(f"Error creating model from json: {e}")
        
    def _create_from_path(self):
        '''Creates the model payload using the model path.'''
        try:
            model = NodeDataExtractor()(self.model_path) # load the model from the path
            model_name, _ = NodeNameHandler.handle_name(self.model_path) # get the model name from the path
            model_type, task = self.find_model_type_and_task(model_name, models) # get the model type and task
            
            # create the payload
            return self._create_handler(model, model_name, model_type, task)
        except Exception as e:
            raise ValueError(f"Error loading model from path: {e}")
    
    def _create_handler(self, model: BaseEstimator, model_name: str = None, 
                        model_type: str = None, task:str = None) -> dict:
        '''Creates the payload for the model.'''
        try:
            payload = PayloadBuilder.build_payload(f"Model created: {model_name}", model, model_name, node_type=model_type, task=task)
            # save the model to the disk & database
            NodeSaver()(payload, path=f"core\\nodes\\saved\\models")

            # Remove the actual node object from the payload because it can't be serialized
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error creating model: {e}")

    # extract type and task of a given model_name from the models dictionary
    def find_model_type_and_task(self, model_name: str, models: dict) -> tuple:
        ''' Extract Model Type and Task from the model name.'''
        for model_type in models:
            for task in models.get(model_type):
                if model_name in models.get(model_type).get(task):
                    return model_type, task
        return "general", "general"

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(self.payload)
            self.payload.update({"node_data": node_data})
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
