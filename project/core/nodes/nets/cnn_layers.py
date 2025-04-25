from .base_layer import BaseLayer
from keras.api.layers import Conv2D, MaxPooling2D

class Conv2DLayer(BaseLayer):
    '''Handles Conv2D layer creation.'''
    def __init__(self, prev_node: dict, filters: int, kernel_size: int, strides: int, padding: str, 
                 activation: str, path: str = None, name: str = None, project_id: int = None, cur_id=None, *args, **kwargs):
        '''Initializes the Conv2D object.'''
        self.filters = filters
        self.kernel_size = kernel_size
        self.strides = strides
        self.padding = padding
        self.activation = activation
        self.name = name
        self.layer_path = path
        self.prev_node = self.load_args(prev_node, attr="node_id")
        self.cur_id = cur_id
        self.uid = kwargs.get('uid', None)
        super().__init__(project_id=project_id)

    @property
    def layer_class(self):
        return Conv2D
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        return f"conv2d_{self.cur_id}"
        
    def get_params(self):
        return {"filters": self.filters, 
                "kernel_size": self.kernel_size, 
                "strides": self.strides, 
                "padding": self.padding, 
                "activation": self.activation, 
                "name": self.name,
                }
    
    def payload_configs(self):
        return {
            "message": "Conv2D layer created",
            "node_name": "conv2d_layer",
            "uid": self.uid,
        }


class MaxPool2DLayer(BaseLayer):
    '''Handles MaxPooling2D layer creation.'''
    def __init__(self, prev_node, pool_size: int, strides: int, padding: str, path: str = None, 
                 name: str = None, project_id: int = None, cur_id = None, *args, **kwargs):
        '''Initializes the MaxPooling2D object.'''
        self.pool_size = pool_size
        self.strides = strides
        self.padding = padding
        self.name = name
        self.layer_path = path
        self.prev_node = self.load_args(prev_node, attr="node_id")
        self.cur_id = cur_id
        self.uid = kwargs.get('uid', None)
        super().__init__(project_id=project_id)
    
    @property
    def layer_class(self):
        return MaxPooling2D
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        return f"maxpool2d_{self.cur_id}"
    
    def get_params(self):
        return {"pool_size": self.pool_size, 
                "strides": self.strides, 
                "padding": self.padding, 
                "name": self.name,
                }

    def payload_configs(self):
        return {
            "message": "MaxPooling2D layer created",
            "node_name": "maxpool2d_layer",
            "uid": self.uid,
        }
