from keras.api.layers import Input
from .base_layer import BaseLayer


class InputLayer(BaseLayer):
    '''Handles input layer creation.'''
    def __init__(self, shape: tuple, name: str = None, path: str = None, project_id: int = None, cur_id = None, *args, **kwargs):
        '''Initializes the Input object.'''
        self.shape = shape
        self.name = name
        self.layer_path = path
        self.cur_id = cur_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)

        super().__init__(project_id=project_id)
    
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
            "uid": self.uid,
            "output_ports": self.output_ports,
            "input_ports": self.input_ports,
        }
