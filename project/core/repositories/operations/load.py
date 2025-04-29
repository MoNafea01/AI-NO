import os
import joblib
import base64
from io import BytesIO
from ai_operations.models import Node
from django.core.exceptions import ObjectDoesNotExist
from core.nodes.utils import NodeNameHandler


class NodeLoader:
    """
    ### This Class can only be called   
    (no initialization)     
    it can load a node by its id from database or through its path  
    ## Args: 
    - node_id (int) : id for node in database 
    - path (str) : node path in your device (accepts pkl files only) 
    - from_db (bool) : this term maybe misleading but the meaning of it that    
    you want to return payload information from database (it's important    
    for you determine if you want to return NodeLoader payload or the loaded    
    node payload instead) if true return node payload, else returns 
    node loader payload     
    - return_serialized (bool) : returns data as serialized version (base64)    
    return_path (bool) : return node data as path
    ## Returns 
    Payload (dict) : with node information
    ### Example: 
        - NodeLoader(from_db=True)(node_id=node_id)     
        output: {"node_name": "logistic_regression",...}    
        - NodeLoader(from_db=False)(node_id=node_id)    
        output: {"node_name": "node_loader",...}
    """

    def __init__(self, from_db : bool = True, 
                 return_serialized : bool = False, 
                 return_path : bool = False,
                 return_data : bool = False):
        
        self.from_db = from_db
        self.return_serialized = return_serialized
        self.return_path = return_path
        self.return_data = return_data

    def __call__(
            self, 
            node_id: int = None, 
            project_id: int = None,
            path: str = None, 
            ) -> dict:
        node_id = int(node_id) if node_id else None
        project_id = int(project_id) if project_id else None
        if not (node_id  or path):
            return False, "Either(node_id and project_id) or path must be provided."
        
        try:
            # Load from path if provided
            if path:
                try:
                    node_data = joblib.load(path)
                    node_name, node_id = NodeNameHandler.handle_name(path)
                    return True, self.build_payload(node_data, node_name, node_id, project_id, path)
                except Exception as e:
                    return False, ValueError(f"Error loading node from path: {e}")

            path = None
            # Load from database if no path provided
            node_entry = Node.objects.get(node_id=node_id, project_id=project_id)
            node_path = node_entry.node_data  # Get the stored path
            node_data = node_path
            try:
                if node_path and os.path.exists(node_path):
                    node_data = joblib.load(node_path)
                else:
                    print(Warning(f"Node data file not found at path: {node_path}"))
                    
            except Exception as e:
                return False, f"Error loading node from path: {e}"
                
            return True, self.build_payload(node_data, node_entry.node_name, node_id, project_id, path)
        
        except ObjectDoesNotExist:
            return False, f"Node with node_id {node_id} does not exist in project with id = {project_id}."
        except Exception as e:
            return False, f"Error loading node: {e}"
    
    def build_payload(self, node_data, name, node_id, project_id, path):
        if path:
            self.from_db = False
        payload = {
                "message": f"Node {name} Loaded.",
                "node_name": "node_loader",
                "node_id": id(self),
                "params": {},
                "task": "load_node",
                "node_type": "loader",
                "project": project_id,
                "children": [],
            }
        
            
        if self.from_db:
            payload = Node.objects.filter(node_id=node_id, project_id=project_id).values().first()
            payload.pop("created_at", None)
            payload.pop("updated_at", None)

        if self.return_path:
            node_data = payload.get("node_data")

        if self.return_serialized:
            if path:
                if os.path.exists(path):
                    with open(path, 'rb') as f:
                        node_data = f.read()
            else:
                buffer = BytesIO()
                joblib.dump(node_data, buffer)
                buffer.seek(0)
                node_data = buffer.read()
            node_data = base64.b64encode(node_data).decode()
        
        if self.return_data:
            node_data = payload.get("node_data")
            if node_data and os.path.exists(node_data):
                node_data = joblib.load(node_data)
            else:
                node_data = None
        
        payload.update({"node_data": node_data})
        return payload
