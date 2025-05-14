import os
import joblib
from ai_operations.models import Node


class NodeSaver:
    """
    ### This Class can only be called   
    (no initialization)     
    It saves the node to the database and path provided.   
    ## Args:
    - payload (dict) :  The node payload.   
    path (str) : The path to save the node to.  
    ## Returns: 
    Dictionary with node information.
    """
    def __init__(self, to_db=True, to_path=True):
        self.to_db = to_db
        self.to_path = to_path

    def __call__(
            self, 
            payload: dict, 
            path: str = None
            ) -> dict:
        
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")
        
        message = payload.get('message', "Done")
        node_id = payload.get("node_id")
        node_name = payload.get('node_name')
        params = payload.get('params', {})
        node = payload.get("node_data")
        task = payload.get('task', "general")
        node_type = payload.get('node_type', "general")
        children = payload.get("children", [])
        project_id = payload.get('project_id')
        uid = payload.get('uid')
        # Save to file system and get path
        save_path = None
        if path and self.to_path:
            save_path = rf"{path}/{node_name}_{node_id}.pkl"
            nodes_dir = os.path.dirname(save_path)
            os.makedirs(nodes_dir, exist_ok=True)
            joblib.dump(node, save_path)
        # Save to database with file path instead of binary data
        if save_path:
            save_path = os.path.abspath(save_path)
        if self.to_db:
            Node.objects.update_or_create(
                node_id=node_id,
                project_id=project_id,
                defaults={
                    'node_name': node_name,
                    'message': message,
                    "node_data": save_path,  # Store the path instead of binary data
                    'params': params,
                    'task': task,
                    'node_type': node_type,
                    'children': children,
                    'project_id': project_id,
                    "uid": uid,
                }
            )
        
        return {
            "message": f"Node {node_name} saved.",
            "node_id": node_id,
            "node_name": "node_saver",
            "node_data": save_path,
            "params": {},
            "task": "save",
            "node_type": "saver",
            "children": children,
            "project_id": project_id,
            "uid": uid,
        }