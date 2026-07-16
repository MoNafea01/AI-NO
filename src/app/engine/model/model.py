from ..base_node import BaseNode
from ..configs.defaults import MODELS as models
from ..configs.registry import resolve_node
from ..utils import NodeNameHandler


class Model(BaseNode):
    '''Handles model creation and parameter management.'''
    def __init__(self, **kwargs):
        self.model_name = kwargs.pop("model_name", "")
        self.model_type = kwargs.pop("model_type", "")
        self.task = kwargs.pop("task", "")
        self.node_path = kwargs.pop("model_path", None)
        default_params = self._get_default_params()

        params = kwargs.pop("params", None)
        if isinstance(params, dict):
            for param, value in params.items():
                if param in default_params.keys():
                    default_params[param] = value

        super().__init__(**kwargs)
        user_params = self.params
        self.params = default_params
        if isinstance(user_params, dict):
            self.params.update(user_params)
        self.params["model_name"] = self.model_name
        self.params["model_type"] = self.model_type
        self.params["task"] = self.task

    def execute(self):
        self.payload = self.load_node()
        return self.payload

    def _get_default_params(self) -> dict:
        '''Returns the default parameters for the model.'''
        try:
            return models.get(self.model_name, {}).get('params', {})
        except AttributeError:
            return f"Invalid configuration for model type: {self.model_type}, task: {self.task}, model name: {self.model_name}."

    @property
    def node_class(self):
        return models.get(self.model_name, {}).get('node', None)

    def node_params(self):
        exclude = {"model_name", "model_type", "task"}
        return {k: v for k, v in self.params.items() if k not in exclude}

    def payload_configs(self):
        return {
            "message": f"Model {self.node_name} created",
            "task": self.get_type_task()[1],
            "node_type": "create_model",
            "node_name": self.node_name,
            "out_ports": self.out_ports,
            "in_ports": self.in_ports,
            "displayed_name": self.displayed_name,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "project_id": self.project_id,
            "workflow_id": self.workflow_id,
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
            entry = resolve_node(name)
            if entry:
                return entry["category"], entry["task"]
        return self.model_type, self.task

    def get_folder(self):
        return "model"
