from tensorflow.keras.layers import Dense, Dropout

from .base_layer import BaseLayer


class DenseLayer(BaseLayer):
    """Handles dense layer creation."""

    def __init__(
        self,
        units: int = 128,
        activation: str = "relu",
        path: str = None,
        name: str = None,
        cur_id=None,
        **kwargs,
    ):
        self.units = units
        self.activation = activation
        self.name = name
        self.layer_path = path
        self.cur_id = cur_id
        super().__init__(**kwargs)

    def execute(self):
        return super().execute()

    @property
    def layer_class(self):
        return Dense

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"dense_layer_{self.cur_id}"

    def get_params(self):
        return {"units": self.units, "activation": self.activation}

    def payload_configs(self):
        return {
            "message": "Dense layer created",
            "node_name": "dense_layer",
            "component_id": self.component_id,
            "node_type": "layer",
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "displayed_name": self.displayed_name,
            "location_x": self.location_x,
            "location_y": self.location_y,
        }


class DropoutLayer(BaseLayer):
    """Handles dropout layer creation."""

    def __init__(
        self, rate: float = 0.5, path: str = None, name: str = None, cur_id=None, **kwargs
    ):
        self.rate = rate
        self.layer_path = path
        self.name = name
        self.cur_id = cur_id
        super().__init__(**kwargs)

    def execute(self):
        return super().execute()

    @property
    def layer_class(self):
        return Dropout

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"dropout_{self.cur_id}"

    def get_params(self):
        return {"rate": self.rate}

    def payload_configs(self):
        return {
            "message": "Dropout layer created",
            "node_name": "dropout_layer",
            "component_id": self.component_id,
            "node_type": "layer",
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
        }
