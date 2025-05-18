from keras.api.layers import Dense, Dropout
from .base_layer import BaseLayer


class DenseLayer(BaseLayer):
    '''Handles dense layer creation.'''
    def __init__(self, prev_node, units: int, activation: str, path: str = None, name: str = None, 
                 project_id: int = None, cur_id = None, *args, **kwargs):
        '''Initializes the Dense object.'''
        self.units = units
        self.activation = activation
        self.name = name
        self.layer_path = path
        self.cur_id = cur_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)

        self.prev_node = self.load_args(prev_node, attr="node_id")
        super().__init__(project_id=project_id)

    @property
    def layer_class(self):
        return Dense
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        return f"dense_layer_{self.cur_id}"
    
    def get_params(self):
        return {
            "units": self.units, 
            "activation": self.activation
        }
    
    def payload_configs(self):
        return {
            "message": "Dense layer created",
            "node_name": "dense_layer",
            "uid": self.uid,
            "input_ports": self.input_ports,
            "output_ports": self.output_ports,
            "displayed_name": self.displayed_name,
        }


class DropoutLayer(BaseLayer):
    '''Handles dropout layer creation.'''
    def __init__(self, prev_node, rate: float, path: str = None, name: str = None, project_id: int = None, cur_id = None, *args, **kwargs):
        '''Initializes the Dropout object.'''
        self.rate = rate
        self.layer_path = path
        self.name = name
        self.cur_id = cur_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)

        self.prev_node = self.load_args(prev_node, attr="node_id")
        super().__init__(project_id=project_id)
    
    @property
    def layer_class(self):
        return Dropout
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        return f"dropout_{self.cur_id}"
    
    def get_params(self):
        return {"rate": self.rate
                }
    
    def payload_configs(self):
        return {
            "message": "Dropout layer created",
            "node_name": "dropout_layer",
            "uid": self.uid,
            "input_ports": self.input_ports,
            "output_ports": self.output_ports,
            "displayed_name": self.displayed_name,
        }
