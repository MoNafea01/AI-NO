from ..repositories import NodeSaver, NodeDataExtractor
from .utils import PayloadBuilder
from ..nodes.configs.const_ import SAVING_DIR

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
            if isinstance(node, str):
                return "Failed to create node. Please check the provided parameters."
            
            return self.load_handler(node)
        except Exception as e:
            return f"Error creating node from json: {e}"
    
    def _load_from_path(self):
        try:
            node = NodeDataExtractor()(self.node_path, project_id=self.project_id)
            if isinstance(node, str):
                return "Failed to load node. Please check the provided path."
            return self.load_handler(node)
        except Exception as e:
            return f"Error loading node from path: {e}"
    
    def load_handler(self, node):
        try:
            payload = self.build_payload(node, **self.payload_configs())
            try:
                if self.children:
                    try:
                        payload.update({'children':[self.children]})
                    except Exception as e:
                        return f"Error updating node's children: {e}"

            except Exception as e:
                pass

            # Add project_id to payload if it exists
            if hasattr(self, 'project_id') and self.project_id:
                payload['project_id'] = self.project_id
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, path=rf"{SAVING_DIR}/{project_path}{self.get_folder()}")
            payload.pop("node_data", None)
            return payload
        
        except Exception as e:
            return f"Error creating {self.node_name} node payload: {e}"

    def node_class(self):
        return "node_class method not implemented."
    
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
            node_data = NodeDataExtractor(return_serialized=True)(self.payload, project_id=self.project_id)
            self.payload.update({"node_data": node_data})
        return self.payload
