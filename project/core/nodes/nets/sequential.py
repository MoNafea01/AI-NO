from keras.api.models import Sequential
from ...repositories.node_repository import NodeLoader, NodeDataExtractor
from .base_layer import BaseLayer

global model_id
model_id = 0

class SequentialNet(BaseLayer):
    '''Handles sequential model creation.'''
    def __init__(self, layer: dict|int, name: str = None, path: str = None):
        '''Initializes the Sequential object.'''
        self.name, self.layer_path = self.load_args(name, path)
        self.layer = self.load_args(layer, attr="node_id")
        self.layers, self.layers_names  = self.get_layers()
        self.payload = self.load_layer()
    
    def get_layers(self):
        cur_id = self.layer
        if not self.layer:
            return [], []
        layers_ids = [cur_id]
        while True:
            task = NodeLoader()(cur_id).get("task")
            if task != "neural_network":
                return [], []
            try:
                cur_id = NodeLoader()(cur_id).get("children")[0]
            except IndexError:
                cur_id = None
                
            if not cur_id:
                break
            layers_ids.append(cur_id)
        layers = [NodeDataExtractor()(layer_id) for layer_id in layers_ids][::-1]
        layers_names = list(map(lambda x: x.name, layers))
        return layers, layers_names

    @property
    def layer_class(self):
        return Sequential

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        '''Generates an id for the layer.'''
        global model_id
        model_id += 1
        return f"sequential_model_{model_id}"
    
    def get_params(self):
        return {"layers": self.layers_names, "name": self.name}
    
    def layer_params(self):
        return super().layer_params(layers=self.layers)
    
    def payload_configs(self):
        return {
            "message": "Sequential model created",
            "node_name": "sequential_model",
        }
