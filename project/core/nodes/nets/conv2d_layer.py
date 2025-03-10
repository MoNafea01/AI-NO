from keras.api.layers import Conv2D
from ...repositories.node_repository import NodeSaver, NodeLoader
from .utils import PayloadBuilder

global n_id
n_id = 0

class Conv2DLayer:
    '''Handles Conv2D layer creation.'''
    def __init__(self, prev_node: dict, filters: int, kernel_size: int, strides: int, padding: str, activation: str, path: str = None, name: str = None):
        '''Initializes the Conv2D object.'''
        self.filters = NodeLoader()(filters.get("node_id")).get('node_data') if isinstance(filters, dict) else filters
        self.kernel_size = NodeLoader()(kernel_size.get("node_id")).get('node_data') if isinstance(kernel_size, dict) else kernel_size
        self.strides = NodeLoader()(strides.get("node_id")).get('node_data') if isinstance(strides, dict) else strides
        self.padding = NodeLoader()(padding.get("node_id")).get('node_data') if isinstance(padding, dict) else padding
        self.activation = NodeLoader()(activation.get("node_id")).get('node_data') if isinstance(activation, dict) else activation
        self.prev_node = NodeLoader()(prev_node.get('node_id')).get('node_id') if isinstance(prev_node, dict) else prev_node
        self.name = NodeLoader()(name.get("node_id")).get('node_data') if isinstance(name, dict) else name
        self.layer_path = path
        self.payload = self._create_conv2d()
    
    def _create_conv2d(self) -> dict:
        '''Creates the Conv2D layer payload.'''
        if not self.name:
            self.name = self.gen_id()

        if self.layer_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()

    def _create_from_dict(self) -> dict:
        '''Creates the Conv2D layer payload using json provided.'''
        try:
            conv2d_layer = Conv2D(filters=self.filters, kernel_size=self.kernel_size, strides=self.strides, padding=self.padding, activation=self.activation, name=self.name)
            return self.create_handler(conv2d_layer)
        except Exception as e:
            raise ValueError(f"Error creating Conv2D layer from json: {e}")

    def _create_from_path(self) -> dict:
        '''Creates the Conv2D layer payload using the input path.'''
        try:
            conv2d_layer = NodeLoader()(path=self.layer_path).get("node_data") # load the input from the path given
            return self.create_handler(conv2d_layer)
        except Exception as e:
            raise ValueError(f"Error creating Conv2D layer from path: {e}")
        

    def create_handler(self, conv2d_layer):
        '''Creates the payload.'''
        try:
            payload = PayloadBuilder.build_payload("Conv2D layer created", conv2d_layer, "conv2d_layer",
                                                   params= {"filters": self.filters, "kernel_size": self.kernel_size, "strides": self.strides, "padding": self.padding, "activation": self.activation, "name": conv2d_layer.name})
            
            if self.prev_node:
                payload.update({'children':{"prev_node": self.prev_node}})

            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            payload.pop("node_data", None)

            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating Conv2D layer payload: {e}")
        

    def gen_id(self):
        '''Generates an id for the layer.'''
        global n_id
        n_id += 1
        return f"conv2d_{n_id}"
    
    def __str__(self):
        '''Returns the payload.'''
        return str(self.payload)
    
    def __repr__(self):
        '''Returns the payload.'''
        return str(self.payload)
    
    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(return_serialized=True)(self.payload.get("node_id")).get('node_data')
            self.payload.update({"node_data": node_data})
        return self.payload