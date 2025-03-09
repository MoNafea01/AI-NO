from keras.api.layers import Dropout
from ...repositories.node_repository import NodeSaver, NodeLoader
from .utils import PayloadBuilder

global n_id
n_id = 0

class DropoutLayer:
    '''Handles dropout layer creation.'''
    def __init__(self, prev_node, rate: float, path: str = None, name: str = None):
        '''Initializes the Dropout object.'''
        self.prev_node = NodeLoader()(prev_node.get('node_id')).get('node_id') if isinstance(prev_node, dict) else prev_node
        self.rate = NodeLoader()(rate.get("node_id")).get('node_data') if isinstance(rate, dict) else rate
        self.name = NodeLoader()(name.get("node_id")).get('node_data') if isinstance(name, dict) else name
        self.layer_path = path
        self.payload = self._create_dropout()

    def _create_dropout(self) -> dict:
        '''Creates the dropout layer payload.'''
        if not self.name:
            self.name = self.gen_id()

        if self.layer_path:
            return self._create_from_path()
        else:
            return self._create_from_dict()

    def _create_from_dict(self) -> dict:
        '''Creates the dropout layer payload using json provided.'''
        try:
            dropout_layer = Dropout(rate=self.rate, name=self.name)
            return self.create_handler(dropout_layer)
        except Exception as e:
            raise ValueError(f"Error creating dropout layer from json: {e}")

    def _create_from_path(self) -> dict:
        '''Creates the dropout layer payload using the input path.'''
        try:
            dropout_layer = NodeLoader()(path=self.layer_path).get("node_data") # load the input from the path given
            return self.create_handler(dropout_layer)
        except Exception as e:
            raise ValueError(f"Error creating dropout layer from path: {e}")
    

    def create_handler(self, dropout_layer):
        '''Creates the payload.'''
        try:
            payload = PayloadBuilder.build_payload("Dropout layer created", dropout_layer, "dropout_layer", children={"prev_node" : self.prev_node},
                                                   params= {"rate": self.rate, "name": dropout_layer.name})
            
            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            del payload["node_data"]

            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating dropout layer payload: {e}")
    
    def gen_id(self):
        '''Generates an id for the layer.'''
        global n_id
        n_id += 1
        name = f"dropout_{n_id}"
        return name
    
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
