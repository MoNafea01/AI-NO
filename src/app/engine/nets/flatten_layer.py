from tensorflow.keras.layers import Flatten

from .base_layer import BaseLayer


class FlattenLayer(BaseLayer):
    """Handles flatten layer creation."""

    def __init__(self, path: str = None, name: str = None, cur_id=None, **kwargs):
        self.layer_path = path
        self.name = name
        self.cur_id = cur_id
        super().__init__(**kwargs)

    def execute(self):
        return super().execute()

    @property
    def layer_class(self):
        return Flatten

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"flatten_{self.cur_id}"

    def get_params(self):
        return {}

    def payload_configs(self):
        return {
            "message": "Flatten layer created",
            "node_name": "flatten_layer",
            "component_id": self.component_id,
            "node_type": "layer",
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
        }
