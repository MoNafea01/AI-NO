from .base_layer import BaseLayer
from keras.api.layers import Flatten


class FlattenLayer(BaseLayer):
    '''Handles flatten layer creation.'''
    def __init__(self, prev_node, path: str = None, name: str = None, project_id: int = None, cur_id = None, *args, **kwargs):
        '''Initializes the Flatten object.'''
        self.layer_path = path
        self.name = name
        self.prev_node = self.load_args(prev_node, attr="node_id")
        self.cur_id = cur_id 
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        super().__init__(project_id=project_id)

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
            "uid": self.uid,
            "input_ports": self.input_ports,
            "output_ports": self.output_ports,
            "displayed_name": self.displayed_name,
        }
