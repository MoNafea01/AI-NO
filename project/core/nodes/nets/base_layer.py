from ...repositories.node_repository import NodeSaver, NodeLoader, NodeDataExtractor
from .utils import PayloadBuilder
from ..base_node import BaseNode


class BaseLayer(BaseNode):
    '''Base class for all layers.'''
    def __init__(self, *args, **kwargs):
        self.payload = self.load_layer()
    
    def load_layer(self):
        if not self.name:
            self.name = self.gen_name()
        if self.layer_path:
            return self._load_from_path()
        else:
            return self._load_from_dict()
        
    def _load_from_dict(self):
        try:
            layer = self.layer_class(**self.layer_params())
            return self.load_handler(layer)
        except Exception as e:
            raise ValueError(f"Error creating layer from json: {e}")
    
    def _load_from_path(self):
        try:
            layer = NodeDataExtractor()(self.layer_path)
            return self.load_handler(layer)
        except Exception as e:
            raise ValueError(f"Error loading layer from path: {e}")
    
    def load_handler(self, layer):
        try:
            payload = self.build_payload(layer, **self.payload_configs())
            try:
                if self.prev_node:
                    try:
                        payload.update({'children':[self.prev_node]})
                    except Exception as e:
                        raise ValueError(f"Error updating children: {e}")

            except Exception as e:
                pass

            NodeSaver()(payload, path=f"core\\nodes\\saved\\nn")
            payload.pop("node_data", None)
            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating {self.layer_name} layer payload: {e}")

    def layer_class(self):
        raise NotImplementedError("layer_class method not implemented.")
    
    def build_payload(self, layer, message, node_name):
        payload = PayloadBuilder.build_payload(message, layer, node_name, params=self.get_params())
        return payload
    
    def layer_name(self):
        return super().node_name()
    
    def gen_name(self):
        '''generate an id for the layer'''
        raise NotImplementedError("gen_name method not implemented.")

    def layer_params(self, **kwargs):
        ''' Parameters that passed to actual layer creation'''
        return super().node_params(**kwargs)

    def load_args(self, *args, attr="node_data"):
        '''Loads node_data from the given args.'''
        l = []
        for arg in args:
            if isinstance(arg, dict):
                data = NodeLoader()(arg.get("node_id")).get(attr)
                if data is not None:
                    l.append(data)
            else:
                l.append(arg)
        if len(l) == 1:
            l = l.pop()
        return l
