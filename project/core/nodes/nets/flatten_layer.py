from .base_layer import BaseLayer
from keras.api.layers import Flatten

global flat_id
flat_id = 0

class FlattenLayer(BaseLayer):
    '''Handles flatten layer creation.'''
    def __init__(self, prev_node, path: str = None, name: str = None):
        '''Initializes the Flatten object.'''
        self.layer_path = path
        self.name = name
        self.prev_node = self.load_args(prev_node, attr="node_id")
        self.payload = self.load_layer()

    @property
    def layer_class(self):
        return Flatten
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        '''Generates an id for the layer.'''
        global flat_id
        flat_id += 1
        return f"flatten_{flat_id}"
    
    def get_params(self):
        return {"name": self.name}
    
    def payload_configs(self):
        return {
            "message": "Flatten layer created",
            "node_name": "flatten_layer",
        }
