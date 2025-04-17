from keras.api.layers import Input
from .base_layer import BaseLayer

global input_id
input_id = 0

class InputLayer(BaseLayer):
    '''Handles input layer creation.'''
    def __init__(self, shape: tuple, name: str = None, path: str = None, project_id: int = None, *args, **kwargs):
        '''Initializes the Input object.'''
        self.shape = shape
        self.name = name
        self.layer_path = path
        super().__init__(project_id=project_id)
    
    @property
    def layer_class(self):
        return Input
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        '''Generates an id for the layer.'''
        global input_id
        input_id += 1
        return f"input_layer_{input_id}"
    
    def get_params(self):
        return {"shape": self.shape, "name": self.name}
    
    def payload_configs(self):
        return {
            "message": "Input layer created",
            "node_name": "input_layer",
        }
