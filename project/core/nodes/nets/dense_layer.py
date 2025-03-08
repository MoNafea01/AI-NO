from keras.api.layers import Dense
from ...repositories.node_repository import NodeSaver, NodeLoader
from .utils import PayloadBuilder

global n_id
n_id = 0

class DenseLayer:
    '''Handles dense layer creation.'''
    def __init__(self, prev_node, units: int, activation: str, path: str = None, name: str = None):
        '''Initializes the Dense object.'''
        self.prev_node = NodeLoader(from_db=True)(prev_node.get('node_id')).get('node_id') if isinstance(prev_node, dict) else prev_node
        self.units = NodeLoader()(units.get("node_id")).get('node_data') if isinstance(units, dict) else units 
        self.activation = NodeLoader()(activation.get("node_id")).get('node_data') if isinstance(activation, dict) else activation
        self.name = NodeLoader()(name.get("node_id")).get('node_data') if isinstance(name, dict) else name
        self.layer_path = path
        self.payload = self._create_dense()

    def _create_dense(self) -> dict:
        '''Creates the dense layer payload.'''
        if not self.name:
            self.name = self.gen_id()

        if self.layer_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()

    def _create_from_dict(self) -> dict:
        '''Creates the dense layer payload using json provided.'''
        try:
            dense_layer = Dense(units=self.units, activation=self.activation, name=self.name)
            return self.create_handler(dense_layer)
        except Exception as e:
            raise ValueError(f"Error creating dense layer from json: {e}")

    def _create_from_path(self) -> dict:
        '''Creates the dense layer payload using the input path.'''
        try:
            layer_path = NodeLoader()(path=self.layer_path).get("node_data") # load the input from the path given
            return self.create_handler(layer_path)
        except Exception as e:
            raise ValueError(f"Error creating dense layer from path: {e}")
    

    def create_handler(self, dense_layer):
        '''Creates the payload.'''
        print(dense_layer)
        try:
            payload = PayloadBuilder.build_payload("Dense layer created", dense_layer, "dense_layer", children={"previous_node" : self.prev_node},
                                                   params= {"units": self.units, "activation": self.activation, "name": dense_layer.name})
            
            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            del payload["node_data"]

            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating dense layer payload: {e}")
    
    def gen_id(self):
        global n_id
        n_id += 1
        name = f"dense_layer_{n_id}"
        return name
    
    def __str__(self):
        return str(self.payload)
    
    def __repr__(self):
        return str(self.payload)
    
    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(from_db=True, return_serialized=True)(self.payload.get("node_id")).get('node_data')
            self.payload.update({"node_data": node_data})
        return self.payload