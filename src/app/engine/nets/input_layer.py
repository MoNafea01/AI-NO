from tensorflow.keras.layers import Input

from .base_layer import BaseLayer


class InputLayer(BaseLayer):
    """Handles input layer creation."""

    def __init__(self, shape=None, name: str = None, path: str = None, cur_id=None, **kwargs):
        self.shape = shape or (None,)
        self.name = name
        self.layer_path = path
        self.cur_id = cur_id
        super().__init__(**kwargs)

    @property
    def layer_class(self):
        return Input

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"input_layer_{self.cur_id}"

    def get_params(self):
        return {"shape": self.shape}

    def payload_configs(self):
        return {
            "message": "Input layer created",
            "node_name": "input_layer",
            "component_id": self.component_id,
            "node_type": "layer",
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
        }
