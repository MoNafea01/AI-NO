from ..repositories.node_repository import NodeSaver, NodeDataExtractor
from .utils import PayloadBuilder

class BaseNode:
    '''Base class for all nodes.'''
    def __init__(self, *args, **kwargs):
        self.project_id = kwargs.get('project_id')  # Get project_id from kwargs
        self.payload = self.load_node()
    
    def load_node(self):
        if self.node_path:
            return self._load_from_path()
        else:
            return self._load_from_dict()
        
    def _load_from_dict(self):
        try:
            node = self.node_class(**self.node_params())
            return self.load_handler(node)
        except Exception as e:
            raise ValueError(f"Error creating node from json: {e}")
    
    def _load_from_path(self):
        try:
            node = NodeDataExtractor()(self.node_path)
            return self.load_handler(node)
        except Exception as e:
            raise ValueError(f"Error loading node from path: {e}")
    
    def load_handler(self, node):
        try:
            payload = self.build_payload(node, **self.payload_configs())
            try:
                if self.children:
                    try:
                        payload.update({'children':[self.children]})
                    except Exception as e:
                        raise ValueError(f"Error updating children: {e}")

            except Exception as e:
                pass

            # Add project_id to payload if it exists
            if hasattr(self, 'project_id') and self.project_id:
                payload['project_id'] = self.project_id

            NodeSaver()(payload, path=f"core/nodes/saved/{self.get_folder()}")
            payload.pop("node_data", None)
            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating {self.node_name} node payload: {e}")

    def node_class(self):
        raise NotImplementedError("node_class method not implemented.")
    
    def build_payload(self, node, message, node_name, **kwargs):
        payload = PayloadBuilder.build_payload(message, node, node_name, params=self.get_params())
        if kwargs:
            payload.update(kwargs)
        return payload
    
    def node_name(self):
        '''Node name'''
        raise NotImplementedError("node_name method not implemented.")
    
    def get_params(self):
        raise NotImplementedError("get_params method not implemented.")
    
    def get_folder(self):
        raise NotImplementedError("get_folder method not implemented.")

    def node_params(self, **kwargs):
        params = self.get_params()
        params.update(kwargs) if kwargs else {}
        return params
    
    def payload_configs(self):
        raise NotImplementedError("payload_configs method not implemented.")

    def __str__(self):
        return str(self.payload)
    
    def __repr__(self):
        return str(self.payload)
    
    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(self.payload)
            self.payload.update({"node_data": node_data})
        return self.payload
