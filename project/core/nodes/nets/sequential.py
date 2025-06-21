from keras.api.models import Sequential
from ...repositories import NodeLoader, NodeDataExtractor
from .base_layer import BaseLayer

class SequentialNet(BaseLayer):
    '''Handles sequential model creation.'''
    def __init__(self, layer: dict|int, name: str = None, path: str = None, project_id: int = None, cur_id = None,*args, **kwargs):
        '''Initializes the Sequential object.'''
        self.name, self.layer_path = self.load_args(name, path)
        self.layer = self.load_args(layer, attr="node_id")
        self.layers, self.layers_names, self.prev_node  = self.get_layers(project_id)
        err = None
        if self.layers == []:
            err = "No layers found in the model or there is an incorrect layer id."

        self.cur_id = cur_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        super().__init__(project_id=project_id, err=err)

    
    def get_layers(self, project_id):
        cur_id = self.layer
        if not self.layer:
            return [], [], None
        
        layers_ids = [cur_id]
        while True:
            success, cur_node = NodeLoader()(cur_id, project_id=project_id)
            if not success:
                return [], [], None
            task = cur_node.get("task")
            if task != "neural_network":
                return [], [], None
            
            parent = cur_node.get("parent", [])
            cur_id = parent[0] if len(parent) == 1 else None
                
            if not cur_id:
                break
            layers_ids.append(cur_id)
        layers = [NodeDataExtractor()(layer_id, project_id=project_id) for layer_id in layers_ids][::-1]
        layers_names = list(map(lambda x: x.name, layers))
        return layers, layers_names, layers_ids[0]

    @property
    def layer_class(self):
        return Sequential

    @property
    def layer_name(self):
        return self.gen_name()

    def gen_name(self):
        return f"sequential_model_{self.cur_id}"
    
    def get_params(self):
        return {}
    
    def layer_params(self):
        return super().layer_params(layers=self.layers)
    
    def payload_configs(self):
        return {
            "message": "Sequential model created",
            "node_name": "sequential_model",
            "uid": self.uid,
            "input_ports": self.input_ports,
            "output_ports": self.output_ports,
            "displayed_name": self.displayed_name,
        }
