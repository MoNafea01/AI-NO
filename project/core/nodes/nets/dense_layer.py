from keras.api.layers import Dense, Input
from ...repositories.node_repository import NodeSaver, NodeLoader
from .utils import PayloadBuilder

class DenseLayer:
    '''Handles dense layer creation.'''
    def __init__(self, units: int, prev_node, activation: str, path: str = None):
        '''Initializes the Dense object.'''
        self.units = NodeLoader()(units.get("node_id")).get('node_data') if isinstance(units, dict) else units 
        self.activation = NodeLoader()(activation.get("node_id")).get('node_data') if isinstance(activation, dict) else activation
        self.prev_node = prev_node
        self.layer_path = path
        self.payload = self._create_dense()

    def _create_dense(self) -> dict:
        '''Creates the dense layer payload.'''
        if self.layer_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()

    def _create_from_dict(self) -> dict:
        '''Creates the dense layer payload using json provided.'''
        try:
            prev_node = NodeLoader()(self.prev_node.get("node_id")).get('node_data') if isinstance(self.prev_node, dict) else self.prev_node
            prev_node = Input(shape=prev_node.shape[1:], name="reloaded_input")
            return self.create_handler(Dense(units=self.units, activation=self.activation)(prev_node))
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
            payload = PayloadBuilder.build_payload("Dense layer created", dense_layer, "dense_layer", 
                                                   params= {"units": self.units, "activation": self.activation})
            
            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            del payload["node_data"]

            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating dense layer payload: {e}")
    
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