from ...repositories import NodeSaver, NodeLoader, NodeDataExtractor
from .utils import PayloadBuilder
from ..base_node import BaseNode, SAVING_DIR

class BaseLayer(BaseNode):
    '''Base class for all layers.'''
    def __init__(self, *args, **kwargs):
        self.project_id = kwargs.get('project_id')
        err = kwargs.get('err', None)
        self.payload = self.load_layer(err=err)
    
    def load_layer(self, err=None):
        if err:
            return err
        if not self.name:
            self.name = self.gen_name()
        if self.layer_path:
            return self._load_from_path()
        else:
            return self._load_from_dict()
        
    def _load_from_dict(self):
        try:
            layer = self.layer_class(**self.layer_params())
            if isinstance(layer, str):
                return "Failed to create layer. Please check the provided parameters."
            return self.load_handler(layer)
        except Exception as e:
            return f"Error creating layer from json: {e}"
    
    def _load_from_path(self):
        try:
            layer = NodeDataExtractor()(self.layer_path, project_id=self.project_id)
            if isinstance(layer, str):
                return "Failed to load layer. Please check the provided path."
            return self.load_handler(layer)
        except Exception as e:
            return f"Error loading layer from path: {e}"
    
    def load_handler(self, layer):
        try:
            payload = self.build_payload(layer, **self.payload_configs())
            try:
                if self.prev_node:
                    try:
                        payload.update({'children':[self.prev_node]})
                    except Exception as e:
                        return f"Error updating children: {e}"

            except Exception as e:
                pass

            if hasattr(self, 'project_id') and self.project_id:
                payload['project_id'] = self.project_id

            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, path=rf"{SAVING_DIR}/{project_path}nets")
            payload.pop("node_data", None)
            return payload
        
        except Exception as e:
            return f"Error creating {self.layer_name} layer payload: {e}"

    def layer_class(self):
        return NotImplementedError("layer_class method not implemented.")
    
    def build_payload(self, layer, message, node_name, **kwargs):
        payload = PayloadBuilder.build_payload(message, layer, node_name, params=self.get_params(), **kwargs)
        return payload
    
    def layer_name(self):
        return super().node_name()
    
    def gen_name(self):
        '''generate an id for the layer'''
        return NotImplementedError("gen_name method not implemented.")

    def layer_params(self, **kwargs):
        ''' Parameters that passed to actual layer creation'''
        return super().node_params(**kwargs)

    def load_args(self, *args, attr="node_data"):
        '''Loads node_data from the given args.'''
        l = []
        for arg in args:
            if isinstance(arg, dict):
                success, data = NodeLoader()(arg.get("node_id"))
                data = data.get(attr)
                if data is not None:
                    l.append(data)
            else:
                l.append(arg)
        if len(l) == 1:
            l = l.pop()
        return l
