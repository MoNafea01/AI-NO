import joblib
from io import BytesIO
import base64
from ai_operations.models import Node, Component
from django.core.exceptions import ObjectDoesNotExist
from ..nodes.utils import NodeDirectoryManager, NodeNameHandler, DirectoryManager
import os


"""
Saving & Loading Operation:
---------------------------
Saving(to db):  
    Object     -> I/O Object | dump it into IO buffer using joblib
    I/O Object -> Binary     | read buffer
    Binary     -> DB         | save method
---------------------------                         
Loading(from db):                
    DB         -> Binary     | get method
    Binary     -> I/O Object | pass it to BytesIO
    I/O Object -> Object     | load it using joblib
"""


MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter"]
SPECIAL_CASE_NODES = ["fitter_transformer"]
PARENT_NODES = ["dense_layer"]


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
        node_id = payload.get('node_id')
        node_name = payload.get('node_name')
        params = payload.get('params', {})
        node = payload.get('node_data')
        task = payload.get('task', "general")
        node_type = payload.get('node_type', "general")
        children = payload.get("children", {})
        
        # save to path
        if path:
            path = f"{path}\\{node_name}_{node_id}.pkl"
            nodes_dir = os.path.dirname(path)
            DirectoryManager.make_dirs(nodes_dir)
            joblib.dump(node, path)

        """
        Saving(to db):  
            Object     -> I/O Object | dump it into IO buffer using joblib
            I/O Object -> Binary     | read buffer
            Binary     -> DB         | save method
        """

        # Prepare node_data
        buffer = BytesIO()          # create an object
        joblib.dump(node, buffer)   # save data into buffer
        buffer.seek(0)              # go to the start of the buffer
        node_bytes = buffer.read()  # read buffer (convert it into binary)

        # Save to database
        Node.objects.update_or_create(
            node_id=node_id,
            defaults={
                'node_name': node_name,
                'message': message,
                'node_data': node_bytes,
                'params': params,
                'task': task,
                'node_type': node_type,
                'children': children
            }
        )
        # returns node_saver payload for preview
        return {"message": f"Node {node_name} saved.",
                "node_id": node_id,
                "node_name": "node_saver",
                "params": {},
                "task": "save",
                "node_type": "saver",
                "children": children
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
    return_bytes (bool) : return node data as binary (not object)   
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
                 return_bytes : bool = False):
        
        self.from_db = from_db
        self.return_serialized = return_serialized
        self.return_bytes = return_bytes

    def __call__(
            self, 
            node_id: int = None, 
            path: str = None, 
            ) -> dict:
        
        if not (node_id or path):
            raise ValueError("Either node_id or path must be provided.")
        
        try:

            if isinstance(path, str):
                try:
                    # Loading node from a path using joblib (We have used pkl format for nodes saving)
                    node_data = joblib.load(path)
                    # node_data now is loaded, we need to get its name, and id to create a payload for it
                    # payload isn't a necessary thing, but we use it to identify a node
                    node_name, node_id = NodeNameHandler.handle_name(path)
                    return self.build_payload(node_data, node_name, node_id)
                
                except Exception as e:
                    raise ValueError(f"Error loading node from path: {e}")
                
            """
            Loading(from db):                
                DB         -> Binary     | get method
                Binary     -> I/O Object | pass it to BytesIO
                I/O Object -> Object     | load it using joblib
            """  

            # load the node from database
            node_entry = Node.objects.get(node_id=node_id)
            node_data = node_entry.node_data    # get the binary node_data
            buffer = BytesIO(node_data)         # return an I/O object to buffer variable
            node_name = node_entry.node_name    # get the node_name, we will need it for payload
            # load the object whatever it is through joblib
            return self.build_payload(joblib.load(buffer), node_name, node_id)
        
        except ObjectDoesNotExist:
            raise ValueError(f"Node with node_id {node_id} does not exist.")
        
        except Exception as e:
            raise ValueError(f"Error loading node: {e}")
    
    def build_payload(self, node_data, name, node_id=None):
        payload = {
                "message": f"Node {name} Loaded.",
                "node_name": "node_loader",
                "node_id": id(self),
                "params": {},
                "task": "load_node",
                "node_type": "loader",
                "children": {},
            }
        
        if self.from_db: # returns node information
            payload = Node.objects.filter(node_id = node_id).values().first()
            payload.pop("created_at"), payload.pop("updated_at") # removed them to avoid time-date serialization error occured
            """
            from_db must be True to return node_data as binary
            """
            if self.return_bytes: # retrieve binaries for node, it should be True & from_db=True
                node_data = payload.pop("node_data")

        if self.return_serialized:
            # this function makes sure that node_data is a binary data, if not then get it
            # from database as we want to serialize it
            if not isinstance(node_data, bytes):
                node_data = Node.objects.filter(node_id = node_id).values().first().pop("node_data")
            node_data = base64.b64encode(node_data).decode()
        
        payload.update({"node_data": node_data})

        return payload



class NodeDeleter:
    """
    ### This Class can only be called   
    (no initialization) 
    ## Args:    
    - node_id (int) : id for node from database   
    - is_special_case (bool) : for nodes have files in distinguished directories   
    - is_multiple_channel (bool) : for nodes haved multiple files at same directory   
    ## Description:
    To delete a node, it's an easy task if the data is saved in database only,  
    but our software also saves it into a backup folder organized   
    into 3 main categories: {models, preprocessors, data},  
    so our task is much harder we need to identify if this node saves its   
    files into multiple directories (special_case), and identify if it saves    
    multiple files or not (multiple_channel) 
    ## Returns: 
    success message
    """

    def __init__(self, is_special_case : bool = False, 
                 is_multi_channel :bool = False):
        
        self.is_special_case = is_special_case
        self.is_multi_channel = is_multi_channel

    def __call__(
            self, 
            node_id, 
            ) -> tuple:

        if not node_id:
            raise ValueError("Node ID must be provided.")
        # make sure that node_id is integer
        node_id = int(node_id) if node_id else None
        try:
            
            node = Node.objects.get(node_id=node_id) # get node from database
            node_name = node.node_name               # get its name
            
            # define the folder that node is saved into
            folder = get_folder_by_task(node.task)
            # delete node from folder and db

            # if we have our node files in multiple directories, then we will try to delete it
            folders = None
            if self.is_multi_channel:
                folders = ['data', 'data']
            elif self.is_special_case:
                folders = ['preprocessors', 'data']

            if folders:
                for folder in folders:
                    old_node = Node.objects.filter(node_id = node_id)
                    children = old_node.values().first().get("children")
                    if children:
                        for key, value in children.items():
                            child = Node.objects.filter(node_id = value)
                            if child.exists():
                                child.delete()
                                delete_node_file(node_name, value, folder)

            delete_node_file(node_name, node_id, folder)
            node.delete()

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
            
            """
            What we are doing exactly??
            We want to update a node, so we take the node_id and create another node with 
            the new configurations and then assign the old node's node_id to it and remove
            the old one from db and file storage
            """

            # take the <old> node (by its id)
            node = Node.objects.get(node_id=node_id)
            new_task = payload.get('task', node.task)   # get new node's task
            folder = get_folder_by_task(new_task)       # determine its folder
            
            # get new node's path
            folder_path = NodeDirectoryManager.get_nodes_dir(folder)
            original_id = payload.get("node_id") # id for new node
            
            # next section for nodes with multiple directiories
            folders = None
            payload['node_data'] = []
            is_multi_channel = node.node_name in MULTI_CHANNEL_NODES
            is_special_case = node.node_name in SPECIAL_CASE_NODES
            
            if is_multi_channel:
                folders = ['data', 'data']
            elif is_special_case:
                folders = ['preprocessors', 'data']
            else:
                payload['node_data'] = NodeLoader()(original_id).get('node_data')

            if folders:
                o_ids = list(payload.get("children").values())
                new_ids = list(Node.objects.filter(node_id = node_id).values().first().get("children").values())
                configs = []
                for o_id in o_ids:
                    config = NodeLoader()(o_id)
                    config.pop("node_id"), config.pop("node_data")
                    configs.append(config)

                for i, f in enumerate(folders):
                    f_path = NodeDirectoryManager.get_nodes_dir(f)
                    tmp_id = o_ids[i]
                    new_id = new_ids[i]
                    data = NodeLoader()(tmp_id).get('node_data')
                    
                    new_payload = payload.copy()
                    new_payload['node_id'] = new_id
                    new_payload['node_data'] = data
                    new_payload.update(**configs[i])
                    payload['node_data'].append(data)
                    NodeSaver()(new_payload, path=f_path)
                    NodeDeleter()(tmp_id)
            
            # now we assign the old node's id for the new node so it takes same identifier
            payload['node_id'] = node_id
            if payload['node_name'] not in PARENT_NODES:
                payload['children'] = node.children
                
            NodeSaver()(payload, path=folder_path)      # ...وتوتة توتة خلصت الحدوتة الحمدلله
            NodeDeleter(is_special_case, is_multi_channel)(original_id)
            
            # this part to delete node if its name isn't same as new one's name
            if node.node_name != payload.get("node_name"):
                delete_node_file(node.node_name, node.node_id,folder)

            # serialization part
            node_data = NodeLoader(return_serialized=self.return_serialized)(node_id).get('node_data')
            message = f"Node {node_id} updated."
            payload.update({"message": message, "node_data": node_data})
            return True, payload
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            return False, f"Error updating node: {e}"


class ClearAllNodes:
    """Clears all nodes from the database and filesystem."""
    def __call__(self, *args):
        try:
            for arg in args:
                if arg == 'components':
                    Component.objects.all().delete()
                    return True, "All components cleared."
                
            # deletes all objects in the Node model
            Node.objects.all().delete()
            nodes_dir = NodeDirectoryManager.get_nodes_dir()

            for folder in os.listdir(nodes_dir):
                folder_path = os.path.join(nodes_dir, folder)
                for file in os.listdir(folder_path):
                    file_path = os.path.join(folder_path, file)
                    if os.path.isfile(file_path):
                        os.remove(file_path)

            return True, "All nodes cleared."
        except Exception as e:
            return False, f"Error clearing nodes: {e}"
    


def get_folder_by_task(task: str) -> str:
    if task in {"regression", "classification", "fit_model"}:
        return "models"
    elif task in {"preprocessing", "fit_preprocessor", "fit_transform"}:
        return "preprocessors"
    elif task in {"neural_network"}:
        return "nn"
    else:
        return "data"


def delete_node_file(node_name, node_id, folder):
    """
    Deletes a single node file from the folder if it exists.
    """
    node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{node_id}.pkl")
    if os.path.exists(node_path):
        os.remove(node_path)



# class NodeRepository:
#     def save_node(self, payload, path: str = None):
#         return NodeSaver()(payload, path)
    
#     def load_node(self, node_id=None, path=None):
#         return NodeLoader()(node_id, path)
    
#     def delete_node(self, node_id: str, is_special_case=False, 
#                     is_multi_channel=False):
#         return NodeDeleter()(node_id, is_special_case, is_multi_channel)    
#     def update_node(self, node_id, payload):
#         return NodeUpdater()(node_id, payload)
    
#     def clear_all_nodes(self, *args):
#         return ClearAllNodes()(*args)