from ..base_node import BaseNode
from ..configs.models import MODELS as models
from ..utils import NodeNameHandler


class Model(BaseNode):
    '''Handles model creation and parameter management.'''
    def __init__(self, model_name: str, model_type: str, task: str, 
                 params: dict = None, model_path: str = None, project_id: int = None, *args, **kwargs) -> dict:
        '''Initializes the Model object.'''
        self.model_name = model_name
        self.model_type = model_type
        self.task = task
        self.node_path = model_path
        default_params = self._get_default_params()

        if isinstance(params, dict):
            for param, value in params.items():
                if param in default_params.keys():
                    default_params[param] = value

        self.params = default_params
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        super().__init__(project_id=project_id)  # Pass project_id to BaseNode
    
    def _get_default_params(self) -> dict:
        '''Returns the default parameters for the model.'''
        try:
            return models.get(self.model_type, {}).get(self.task, {}).get(self.model_name, {}).get('params', {})
        except AttributeError:
            return f"Invalid configuration for model type: {self.model_type}, task: {self.task}, model name: {self.model_name}."
    
    @property
    def node_class(self):
        return models.get(self.model_type, {}).get(self.task, {}).get(self.model_name, {}).get('node', None)
    
    def node_params(self):
        return self.params
    
    def payload_configs(self):
        return {
            "message": f"Model {self.node_name} created",
            "task": self.get_type_task()[1],
            "node_type": self.get_type_task()[0],
            "node_name": self.node_name,
            "uid": self.uid,
            "output_ports": self.output_ports,
            "input_ports": self.input_ports,
            "displayed_name": self.displayed_name,
            "location_x": 400.0,
            "location_y": 600.0,
            "project_id": self.project_id,
        }
    
    def get_params(self):
        return self.params
    
    @property
    def node_name(self):
        if self.node_path:
            self.model_name, _ = NodeNameHandler.handle_name(self.node_path)
        return self.model_name
    
    def get_type_task(self):
        if self.node_path:
            name = self.node_name
            for model_type in models:
                for task in models.get(model_type):
                    if name in models.get(model_type).get(task):
                        return model_type, task
        return self.model_type, self.task

    def get_folder(self):
        return "model"
