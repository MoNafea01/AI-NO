from tensorflow.keras.layers import Conv2D, MaxPooling2D

from .base_layer import BaseLayer


class Conv2DLayer(BaseLayer):
    """Handles Conv2D layer creation."""

    def __init__(
        self,
        filters: int = 32,
        kernel_size=None,
        strides=None,
        padding: str = "valid",
        activation: str = "relu",
        path: str = None,
        name: str = None,
        cur_id=None,
        **kwargs,
    ):
        self.filters = filters
        self.kernel_size = kernel_size or [3, 3]
        self.strides = strides or [1, 1]
        self.padding = padding
        self.activation = activation
        self.name = name
        self.layer_path = path
        self.cur_id = cur_id
        super().__init__(**kwargs)

    def execute(self):
        return super().execute()

    @property
    def layer_class(self):
        return Conv2D

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"conv2d_{self.cur_id}"

    def get_params(self):
        return {
            "filters": self.filters,
            "kernel_size": self.kernel_size,
            "strides": self.strides,
            "padding": self.padding,
            "activation": self.activation,
        }

    def payload_configs(self):
        return {
            "message": "Conv2D layer created",
            "node_name": "conv2d_layer",
            "node_type": "layer",
            "component_id": self.component_id,
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "displayed_name": self.displayed_name,
            "location_x": self.location_x,
            "location_y": self.location_y,
        }


class MaxPool2DLayer(BaseLayer):
    """Handles MaxPooling2D layer creation."""

    def __init__(
        self,
        pool_size=None,
        strides=None,
        padding: str = "valid",
        path: str = None,
        name: str = None,
        cur_id=None,
        **kwargs,
    ):
        self.pool_size = pool_size or [2, 2]
        self.strides = strides or [2, 2]
        self.padding = padding
        self.name = name
        self.layer_path = path
        self.cur_id = cur_id
        super().__init__(**kwargs)

    def execute(self):
        return super().execute()

    @property
    def layer_class(self):
        return MaxPooling2D

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"maxpool2d_{self.cur_id}"

    def get_params(self):
        return {"pool_size": self.pool_size, "strides": self.strides, "padding": self.padding}

    def payload_configs(self):
        return {
            "message": "MaxPooling2D layer created",
            "node_name": "maxpool2d_layer",
            "node_type": "layer",
            "component_id": self.component_id,
            "in_ports": self.in_ports,
            "out_ports": self.out_ports,
            "location_x": self.location_x,
            "location_y": self.location_y,
            "displayed_name": self.displayed_name,
        }
