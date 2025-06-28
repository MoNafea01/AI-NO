import os, copy
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
            o_payload: dict, 
            path: str = None
            ) -> dict:
        
        payload = copy.deepcopy(o_payload)
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
        parent = payload.get("parent", [])
        project_id = payload.get('project_id')
        location_x = payload.get('location_x', 0.0)
        location_y = payload.get('location_y', 0.0)
        uid = payload.get('uid')
        input_ports = payload.get('input_ports', [])
        output_ports = NodeSaver.update_output_ports(node_id, payload.get('output_ports', []))
        displayed_name = payload.get('displayed_name', "default")
        # Save to file system and get path
        save_path = None
        if path and self.to_path:
            save_path = rf"{path}/{node_name}_{node_id}.pkl"
            if task == "save_template":
                save_path = rf"{path}/{node_name}.pkl"
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
                    'parent': parent,
                    'project_id': project_id,
                    "uid": uid,
                    'location_x': location_x,
                    'location_y': location_y,
                    'input_ports': input_ports,
                    'output_ports': output_ports,
                    'displayed_name': displayed_name,
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
            'parent': parent,
            "project_id": project_id,
            "uid": uid,
            "location_x": location_x,
            "location_y": location_y,
            "input_ports": input_ports,
            "output_ports": output_ports,
            "displayed_name": displayed_name,
        }
    
    @staticmethod
    def update_output_ports(node_id, output_ports):
        new_ports = []
        for port in output_ports:
            if isinstance(port, dict):
                new_port = port.copy()
                new_port.update({"nodeData": node_id})
                new_ports.append(new_port)
        return new_ports
