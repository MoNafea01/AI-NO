from keras.api.layers import Dense, Dropout
from .base_layer import BaseLayer

global dense_id
global dropout_id

dense_id = 0
dropout_id = 0

class DenseLayer(BaseLayer):
    '''Handles dense layer creation.'''
    def __init__(self, prev_node, units: int, activation: str, path: str = None, name: str = None):
        '''Initializes the Dense object.'''
        self.units, self.activation, self.name, self.layer_path = self.load_args(units, activation, name, path)
        self.prev_node = self.load_args(prev_node, attr="node_id")
        self.payload = self.load_layer()

    @property
    def layer_class(self):
        return Dense
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        '''Generates an id for the layer.'''
        global dense_id
        dense_id += 1
        return f"dense_layer_{dense_id}"
    
    def get_params(self):
        return {
            "units": self.units, 
            "activation": self.activation, 
            "name": self.name
        }
    
    def payload_configs(self):
        return {
            "message": "Dense layer created",
            "node_name": "dense_layer",
        }


class DropoutLayer(BaseLayer):
    '''Handles dropout layer creation.'''
    def __init__(self, prev_node, rate: float, path: str = None, name: str = None):
        '''Initializes the Dropout object.'''
        self.rate, self.layer_path, self.name = self.load_args(rate, path, name)
        [self.prev_node] = self.load_args(prev_node, attr="node_id")
        self.payload = self.load_layer()
    
    @property
    def layer_class(self):
        return Dropout
    
    @property
    def layer_name(self):
        return self.gen_name()
    
    def gen_name(self):
        '''Generates an id for the layer.'''
        global dropout_id
        dropout_id += 1
        return f"dropout_{dropout_id}"
    
    def get_params(self):
        return {"rate": self.rate, "name": self.name}
    
    def payload_configs(self):
        return {
            "message": "Dropout layer created",
            "node_name": "dropout_layer",
        }