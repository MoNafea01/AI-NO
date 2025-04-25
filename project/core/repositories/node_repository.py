import joblib
import base64
from io import BytesIO
from ai_operations.models import Node, Component
from django.core.exceptions import ObjectDoesNotExist
from ..nodes.utils import NodeNameHandler
from core.nodes.configs.const_ import PARENT_NODES, MULTI_CHANNEL_NODES, SAVING_DIR
from core.nodes.utils import delete_node
import os



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
        node_path = None
        if path:
            node_path = fr"{path}\{node_name}_{node_id}.pkl"
            nodes_dir = os.path.dirname(node_path)
            os.makedirs(nodes_dir, exist_ok=True)
            joblib.dump(node, node_path)
        # Save to database with file path instead of binary data
        if node_path:
            node_path = os.path.abspath(node_path)
            
        Node.objects.update_or_create(
            node_id=node_id,
            defaults={
                'node_name': node_name,
                'message': message,
                "node_data": node_path,  # Store the path instead of binary data
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
            "node_data": node_path,
            "params": {},
            "task": "save",
            "node_type": "saver",
            "children": children,
            "project_id": project_id,
            "uid": uid,
        }



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
            path: str = None, 
            ) -> dict:
        
        if not (node_id or path):
            raise ValueError("Either node_id or path must be provided.")
        
        try:
            # Load from path if provided
            if path:
                try:
                    node_data = joblib.load(path)
                    node_name, node_id = NodeNameHandler.handle_name(path)
                    return self.build_payload(node_data, node_name, node_id, path)
                except Exception as e:
                    raise ValueError(f"Error loading node from path: {e}")

            path = None
            # Load from database if no path provided
            node_entry = Node.objects.get(node_id=node_id)
            node_path = node_entry.node_data  # Get the stored path
            node_data = node_path
            try:
                if node_path and os.path.exists(node_path):
                    node_data = joblib.load(node_path)
                else:
                    print(Warning(f"Node data file not found at path: {node_path}"))
                    
            except Exception as e:
                raise ValueError(f"Error loading node from path: {e}")
                
            return self.build_payload(node_data, node_entry.node_name, node_id, path)
        
        except ObjectDoesNotExist:
            raise ValueError(f"Node with node_id {node_id} does not exist.")
        except Exception as e:
            raise ValueError(f"Error loading node: {e}")
    
    def build_payload(self, node_data, name, node_id, path):
        if path:
            self.from_db = False
        payload = {
                "message": f"Node {name} Loaded.",
                "node_name": "node_loader",
                "node_id": id(self),
                "params": {},
                "task": "load_node",
                "node_type": "loader",
                "children": [],
            }
        
            
        if self.from_db:
            payload = Node.objects.filter(node_id=node_id).values().first()
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



class NodeDeleter:
    """
    ### This Class can only be called   
    (no initialization) 
    ## Args:    
    - node_id (int) : id for node from database   
    - is_multiple_channel (bool) : for nodes haved multiple files at same directory   
    ## Description:
    To delete a node and its dependencies from the database and filesystem.
    ## Returns: 
    success message
    """

    def __init__(self, is_multi_channel :bool = False):
        self.is_multi_channel = is_multi_channel

    def __call__(
            self, 
            node_id, 
            ) -> tuple:

        if not node_id:
            raise ValueError("Node ID must be provided.")
        
        node_id = int(node_id) if node_id else None
        try:
            node = Node.objects.get(node_id=node_id) # get node from database

            if self.is_multi_channel:
                old_node = Node.objects.get(node_id = node_id)
                children = old_node.children
                if children:
                    for value in children:
                        child = Node.objects.get(node_id = value)
                        delete_node(child)
            
            delete_node(node)

            return True, f"Node {node_id} deleted."
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            raise e  # Re-raise for the view to handle



class NodeUpdater:
    """
    ### This Class can only be called   
    (no initialization)     
    ## Args:   
    node_id (int) : id for node in database     
    payload (dict) : node info    
    return_serialized (bool) : return data in serialized version (base64)
    ## Returns: 
    success message
    """
    def __init__(self, return_serialized : bool = False):
        self.return_serialized = return_serialized

    def __call__(self, node_id: int, payload: dict, ) -> tuple:
        if not node_id:
            raise ValueError("Node ID must be provided.")
        
        node_id = int(node_id) if node_id else None
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")
        
        try:
            # take the <old> node (by its id)
            node = Node.objects.get(node_id=node_id)
            folder_path = os.path.dirname(node.node_data)
            original_id = payload.get("node_id") # id for new node
            
            is_multi_channel = node.node_name in MULTI_CHANNEL_NODES
            payload["node_data"] = NodeDataExtractor()(original_id)

            if is_multi_channel:
                payload["node_data"] = []
                configs = []

                o_ids = payload.get("children")
                new_ids = node.children

                for o_id in o_ids:
                    config = NodeLoader()(o_id)
                    configs.append(config)

                for i in range(2):
                    tmp_id = o_ids[i]
                    new_id = new_ids[i]
                    data = NodeDataExtractor()(tmp_id)
                    
                    new_payload = payload.copy()
                    new_payload.update(**configs[i])
                    new_payload.update({"node_id":new_id, "node_data": data})
                    payload["node_data"].append(data)
                    NodeSaver()(new_payload, path=folder_path)
            
            # now we assign the old node's id for the new node so it takes same identifier
            payload["node_id"] = node_id
            if payload['node_name'] not in PARENT_NODES:
                payload['children'] = node.children
                
            NodeSaver()(payload, path=folder_path)
            NodeDeleter(is_multi_channel)(original_id)
            
            # this part to delete node if its name isn't same as new one's name
            if node.node_name != payload.get("node_name"):
                node_path = node.node_data
                if os.path.exists(node_path):
                    os.remove(node_path)

            # serialization part
            out_node = NodeLoader(return_serialized=self.return_serialized)(node_id)
            message = f"Node {out_node.get('node_name')} with id {node_id} updated."
            payload.update({"message": message, "node_data": out_node.get('node_data')})
            return True, payload
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            return False, f"Error updating node: {e}"



class ClearAllNodes:
    """Clears all nodes from the database and filesystem."""
    def __call__(self, *args, **kwargs):
        import shutil
        try:
            for arg in args:
                if arg == 'components':
                    Component.objects.all().delete()
                    return True, "All components cleared."
            project_id = kwargs.get("project_id")
            if project_id:
                project = Node.objects.filter(project_id=project_id)
            else:
                project = Node.objects.all()
            # deletes all objects in the Node model
            nodes_path = SAVING_DIR + "\\" + str(project_id) if project_id else SAVING_DIR
            project.delete()
            nodes_dir = os.path.abspath(SAVING_DIR)
            shutil.rmtree(nodes_path, ignore_errors=True)
            
            f_count = 0
            for *_, files in os.walk(nodes_dir):
                f_count += len(files)

            if not f_count:
                shutil.rmtree(nodes_dir, ignore_errors=True)

            return True, "All nodes cleared."
        except Exception as e:
            return False, f"Error clearing nodes: {e}"



class NodeDataExtractor:
    def __init__(self, from_db : bool = True, return_serialized : bool = False, return_path : bool = False):
        self.from_db = from_db
        self.return_serialized = return_serialized
        self.return_path = return_path

    def __call__(self, *args):
        return self.node_data_extract(*args)

    def node_data_extract(self, *args):
        l = []
        for arg in args:
            if isinstance(arg, dict):
                data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(arg.get("node_id")).get("node_data")
                if data is not None:
                    l.append(data)
            elif isinstance(arg, int):
                data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(arg).get("node_data")
                if data is not None:
                    l.append(data)
            elif isinstance(arg, str):
                if arg.isnumeric():
                    data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(int(arg)).get("node_data")
                else:
                    data = NodeLoader(from_db=False, return_serialized=self.return_serialized, return_path=self.return_path)(path=arg).get("node_data")
                if data is not None:
                    l.append(data)
            else:
                l.append(arg)
        if len(l) == 1:
            l = l.pop()
    
        return l
