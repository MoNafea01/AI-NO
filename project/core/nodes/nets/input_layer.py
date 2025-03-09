

from keras.api.layers import Input as input_layer
from ...repositories.node_repository import NodeSaver, NodeLoader
from .utils import PayloadBuilder

global n_id
n_id = 0

class Input:
    '''Handles input layer creation.'''
    def __init__(self, input_shape: tuple, name: str = None, input_path: str = None):
        '''Initializes the Input object.'''
        self.input_shape = input_shape
        self.name = name
        self.input_path = input_path
        self.payload = self._create_input()

    def _create_input(self) -> dict:
        '''Creates the input layer payload.'''
        if self.input_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()

    def _create_from_dict(self) -> dict:
        '''Creates the input layer payload using json provided.'''
        try:
            input_shape = NodeLoader()(self.input_shape.get("node_id")).get('node_data') if isinstance(self.input_shape, dict) else self.input_shape
            input_name = NodeLoader()(self.name.get("node_id")).get('node_data') if isinstance(self.name, dict) else self.name
            if not input_name:
                input_name = self.gen_id()
            return self.create_handler(input_layer(shape=input_shape, name=input_name))
        except Exception as e:
            raise ValueError(f"Error creating input layer from json: {e}")

    def _create_from_path(self) -> dict:
        '''Creates the input layer payload using the input path.'''
        try:
            input_ = NodeLoader()(path=self.input_path).get("node_data") # load the input from the path given
            return self.create_handler(input_)
        except Exception as e:
            raise ValueError(f"Error creating input layer from path: {e}")
    

    def create_handler(self, input_layer):
        '''Creates the payload.'''
        try:
            payload = PayloadBuilder.build_payload("Input layer created", input_layer, "input_layer", 
                                                   params= {"shape": input_layer.shape,"name": input_layer.name})
            
            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            del payload["node_data"]

            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating input layer payload: {e}")
    
    def gen_id(self):
        global n_id
        n_id += 1
        name = f"input_layer_{n_id}"
        return name

    def __str__(self):
        return str(self.payload)
    
    def __repr__(self):
        return str(self.payload)
    
    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(return_serialized=True)(self.payload.get("node_id")).get('node_data')
            self.payload.update({"node_data": node_data})
        return self.payload


