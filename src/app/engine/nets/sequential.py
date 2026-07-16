from tensorflow.keras.models import Sequential

from ..repositories.execution import EnginePersistence
from .base_layer import BaseLayer

_VALID_LAYER_NAMES = {
    "input_layer",
    "dense_layer",
    "dropout_layer",
    "conv2d_layer",
    "maxpool2d_layer",
    "flatten_layer",
}


class SequentialNet(BaseLayer):
    """Handles sequential model creation using port-based connections."""

    def __init__(
        self,
        name: str = None,
        path: str = None,
        cur_id=None,
        **kwargs,
    ):
        self._raw_name = name
        self._raw_path = path
        self._project_id = kwargs.get("project_id")
        self.cur_id = cur_id
        self._err = None
        super().__init__(**kwargs)

    def execute(self):
        self.name, self.layer_path = self.load_args(self._raw_name, self._raw_path)

        in_ports = self.in_ports or {}
        layer_ref = in_ports.get("layer")
        if layer_ref:
            self.layer = int(str(layer_ref).split(":")[0])
        else:
            self.layer = None

        self.layers, self.layers_names, self.prev_node = self.get_layers(self._project_id)
        if self.layers == []:
            self._err = "No layers found in the model or there is an incorrect layer id."
        else:
            self._validate_network()
        return super().execute()

    def _validate_network(self):
        """Validate the network chain: must start with InputLayer, all layers must be valid types."""
        from tensorflow.keras.layers import Conv2D, Dense, Dropout, Flatten, Input, MaxPooling2D

        _LAYER_TYPE_MAP = {
            Input: "input_layer",
            Dense: "dense_layer",
            Dropout: "dropout_layer",
            Conv2D: "conv2d_layer",
            MaxPooling2D: "maxpool2d_layer",
            Flatten: "flatten_layer",
        }

        first_layer = self.layers[0]
        first_type_name = _LAYER_TYPE_MAP.get(type(first_layer))
        if first_type_name != "input_layer":
            self._err = (
                f"Network must start with an Input layer, "
                f"got {type(first_layer).__name__} ({first_type_name})"
            )
            return

        for i, layer in enumerate(self.layers):
            type_name = _LAYER_TYPE_MAP.get(type(layer))
            if type_name not in _VALID_LAYER_NAMES:
                self._err = (
                    f"Layer at position {i} ({type(layer).__name__}) is not a valid network layer"
                )
                return

    def get_layers(self, project_id):
        cur_id = self.layer
        if not self.layer:
            return [], [], None

        layers_ids = [cur_id]
        while True:
            success, cur_node = EnginePersistence.load_node_meta(cur_id, project_id=project_id)
            if not success:
                return [], [], None
            task = cur_node.get("task")
            if task != "nn":
                return [], [], None

            in_ports = cur_node.get("in_ports", {})
            layer_ref = in_ports.get("layer")
            if layer_ref:
                cur_id = int(str(layer_ref).split(":")[0])
            else:
                break
            layers_ids.append(cur_id)
        layers = [
            EnginePersistence.load_data(layer_id, project_id=project_id) for layer_id in layers_ids
        ][::-1]
        layers_names = list(map(lambda x: x.name, layers))
        return layers, layers_names, layers_ids[0]

    @property
    def layer_class(self):
        return Sequential

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"sequential_model_{self.cur_id}"

    def get_params(self):
        return {}

    def layer_params(self):
        return super().layer_params(layers=self.layers)

    def payload_configs(self):
        return {
            "message": "Sequential model created",
            "node_name": "sequential_model",
            "node_type": "nn_model",
            "component_id": self.component_id,
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
        }
