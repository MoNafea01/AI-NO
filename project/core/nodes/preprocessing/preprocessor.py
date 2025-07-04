from ..base_node import BaseNode
from ..configs.preprocessors import PREPROCESSORS as preprocessors
from ..utils import NodeNameHandler


class Preprocessor(BaseNode):
    """Handles preprocessors creation and parameter management."""
    def __init__(self, preprocessor_name: str, preprocessor_type: str, params: dict = None, preprocessor_path: str = None, 
                 project_id: int = None, *args, **kwargs) -> dict:
        self.preprocessor_name = preprocessor_name
        self.preprocessor_type = preprocessor_type
        self.task = "preprocessing"
        self.node_path = preprocessor_path
        default_params = self._get_default_params()
        if isinstance(params, dict):
            for param, value in params.items():
                if param in default_params.keys():
                    default_params[param] = value

        self.params = default_params
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)

        super().__init__(project_id=project_id)

    def _get_default_params(self) -> dict:
        try:
            return preprocessors.get(self.preprocessor_type, {}).get(
                self.preprocessor_name, {}).get('params', {})
        except AttributeError:
            return f"Invalid configuration for preprocessor type: {self.preprocessor_type}, task: {self.task}, preprocessor name: {self.preprocessor_name}."

    @property
    def node_class(self):
        return preprocessors.get(self.preprocessor_type, {}).get(self.preprocessor_name, {}).get('node', None)

    def node_params(self):
        return self.params

    def payload_configs(self):
        return {
            "message": f"Preprocessor {self.node_name} created",
            "task": "preprocessing",
            "node_type": self.get_type,
            "node_name": self.node_name,
            "uid": self.uid,
            "input_ports": self.input_ports,
            "output_ports": self.output_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
            "project_id": self.project_id,
        }

    def get_params(self):
        return self.params

    @property
    def node_name(self):
        if self.node_path:
            self.preprocessor_name, _ = NodeNameHandler.handle_name(self.node_path)
        return self.preprocessor_name

    def get_folder(self):
        return "preprocessing"
    
    @property
    def get_type(self):
        if self.node_path:
            name = self.node_name
            for node_type in preprocessors:
                if name in preprocessors.get(node_type):
                    return node_type
        return self.preprocessor_type
