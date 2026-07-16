from ..base_node import BaseNode
from ..configs.defaults import PREPROCESSORS as preprocessors
from ..configs.registry import resolve_node
from ..utils import NodeNameHandler


class Preprocessor(BaseNode):
    """Handles preprocessors creation and parameter management."""

    def __init__(self, **kwargs):
        self.preprocessor_name = kwargs.pop("preprocessor_name", "")
        self.preprocessor_type = kwargs.pop("preprocessor_type", "")
        self.task = kwargs.pop("task", "")
        self.node_path = kwargs.pop("preprocessor_path", None)
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
        self.params["preprocessor_name"] = self.preprocessor_name
        self.params["preprocessor_type"] = self.preprocessor_type
        self.params["task"] = self.task

    def execute(self):
        self.payload = self.load_node()
        return self.payload

    def _get_default_params(self) -> dict:
        try:
            return preprocessors.get(self.preprocessor_name, {}).get("params", {})
        except AttributeError:
            return f"Invalid configuration for preprocessor type: {self.preprocessor_type}, task: {self.task}, preprocessor name: {self.preprocessor_name}."

    @property
    def node_class(self):
        return preprocessors.get(self.preprocessor_name, {}).get("node", None)

    def node_params(self):
        exclude = {"preprocessor_name", "preprocessor_type", "task"}
        return {k: v for k, v in self.params.items() if k not in exclude}

    def payload_configs(self):
        return {
            "message": f"Preprocessor {self.node_name} created",
            "task": self.get_type_task[1],
            "node_type": "create_preprocessor",
            "node_name": self.node_name,
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
            "project_id": self.project_id,
            "workflow_id": self.workflow_id,
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
    def get_type_task(self):
        if self.node_path:
            name = self.node_name
            entry = resolve_node(name)
            if entry:
                return entry["category"], entry["task"]
        return self.preprocessor_type, self.task
