from keras.api.models import Sequential
from ...repositories.node_repository import NodeSaver, NodeLoader
from .utils import PayloadBuilder

global n_id
n_id = 0

class SequentialNet:
    '''Handles sequential model creation.'''
    def __init__(self, layer: dict, name: str = None, path: str = None):
        '''Initializes the Sequential object.'''
        self.layer = NodeLoader()(layer.get("node_id")).get('node_id') if isinstance(layer, dict) else layer
        self.name = NodeLoader()(name.get("node_id")).get('node_data') if isinstance(name, dict) else name
        self.layers, self.layers_names  = self.get_layers()
        self.path = path
        self.model = self._create_model()
        self.payload = self._create_payload()

    def _create_model(self) -> Sequential:
        '''Creates the model.'''
        if not self.name:
            self.name = self.gen_id()
        try:
            model = Sequential(self.layers, name=self.name)
            return model
        except Exception as e:
            raise ValueError(f"Error creating model: {e}")

    def _create_payload(self) -> dict:
        '''Creates the payload.'''
        try:
            payload = PayloadBuilder.build_payload("Sequential model created", self.model, "sequential_model", 
                                                   params= {"layers": self.layers_names, "name": self.model.name}, node_type="nn_model")
            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error creating model payload: {e}")
    
    def get_layers(self):
        cur_id = self.layer
        layers_ids = [cur_id]
        while True:
            cur_id = NodeLoader()(cur_id).get("children").get('prev_node')
            if not cur_id:
                break
            layers_ids.append(cur_id)
        layers = [NodeLoader()(layer_id).get('node_data') for layer_id in layers_ids]
        layers_names = [NodeLoader()(layer_id).get('node_data').name for layer_id in layers_ids]
        return layers[::-1], layers_names[::-1]
    
    def gen_id(self):
        global n_id
        n_id += 1
        name = f"sequential_model_{n_id}"
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