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


Loading(from db):                
    DB         -> Binary     | get method
    Binary     -> I/O Object | pass it to BytesIO
    I/O Object -> Object     | load it using joblib
"""


MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter"]
SPECIAL_CASE_NODES = ["fitter_transformer"]


class NodeSaver:
    """
    ### This Class can only be called \n
    (no initialization)\n
    #### It saves the node to the database and path provided.\n
    ## Takes:
    payload: dict - The node payload.\n
    path: str - The path to save the node to.\n
    ## Returns: 
    Dictionary with the message, node_id, node_name, params, task, and node_type.
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
            }
        )
        # returns node_saver payload for preview
        return {"message": f"Node {node_name} saved.",
                "node_id": node_id,
                "node_name": "node_saver",
                "params": {},
                "task": "save",
                "node_type": "saver"
                }



class NodeLoader:
    """
    ### This Class can only be called \n
    (no initialization)\n
    #### it can load a node by its id from database or through its path\n
    ## Takes: \n
    node_id: int - id for node in database \n
    path: str - node path in your device (accepts pkl files only) \n 
    from_db: bool - this term maybe misleading but the meaning of it that 
    you want to return payload information from database (it's important 
    for you determine if you want to return NodeLoader payload or the loaded 
    node payload instead) if true return node payload, else returns
    node loader payload \n 
    return_serialized: bool - returns data as serialized version (base64) \n 
    return_bytes: bool - return node data as binary (not object) \n
    ## Returns \n
    Payload: dict - with node informations
    ### Example: \n
    ``` NodeLoader()(node_id=node_id, from_db=True) 
    output: {"node_name": "logistic_regression",...}\n
    NodeLoader()(node_id=node_id, from_db=False)
    output: {"node_name": "node_loader",...}
    """
    def __call__(
            self, 
            node_id: int = None, 
            path: str = None, 
            from_db: bool = False, 
            return_serialized:bool = False, 
            return_bytes: bool = False
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
                    return self.build_payload(node_data, node_name, from_db, node_id)
                
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
            return self.build_payload(joblib.load(buffer), node_name, from_db, node_id, return_serialized, return_bytes)
        
        except ObjectDoesNotExist:
            raise ValueError(f"Node with node_id {node_id} does not exist.")
        
        except Exception as e:
            raise ValueError(f"Error loading node: {e}")
    
    def build_payload(self, node_data, name, from_db=False, node_id=None, return_serialized=False, return_bytes=False):
        payload = {
                "message": f"Node {name} Loaded.",
                "node_name": "node_loader",
                "node_id": id(self),
                "params": {},
                "task": "load_node",
                "node_type": "loader"
            }
        
        if from_db: # returns node information
            payload = Node.objects.filter(node_id=node_id).values().first()
            payload.pop("created_at"), payload.pop("updated_at") # removed them to avoid time-date serialization error occured
            """
            from_db must be True to return node_data as binary
            """
            if return_bytes: # retrieve binaries for node, it should be True & from_db=True
                node_data = payload.pop("node_data")

        if return_serialized:
            # this function makes sure that node_data is a binary data, if not then get it
            # from database as we want to serialize it
            if not isinstance(node_data, bytes):
                node_data = Node.objects.filter(node_id=node_id).values().first().pop("node_data")
            node_data = base64.b64encode(node_data).decode()
        
        payload.update({"node_data": node_data})

        return payload



class NodeDeleter:
    """
    ### This Class can only be called \n
    (no initialization)\n
    ## Takes: \n 
    node_id: int - id for node from database\n
    is_special_case: bool - for nodes have files in distinguished directories \n
    is_multiple_channel: bool - for nodes haved multiple files at same directory\n
    to delete a node, it's an easy task if the data is saved in database only, 
    but our software also saves it into a backup folder organized 
    into 3 main categories: {models, preprocessors, data},
    so our task is much harder we need to identify if this node saves its 
    files into multiple directories (special_case), and identify if it saves
    multiple files or not (multiple_channel) 
    ## Returns: \n
    success message
    """
    def __call__(
            self, 
            node_id, 
            is_special_case=False, 
            is_multi_channel=False, 
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
            delete_node_file(node_name, node_id, folder)
            node.delete()

            # if we have our node files in multiple directories, then we will try to delete it
            folders = None
            if is_multi_channel:
                folders = ['data', 'data']
            elif is_special_case:
                folders = ['preprocessors', 'data']

            if folders:
                for folder in folders:
                    # I have made id of our node-related nodes to be more than it with one or 2
                    # for simplicity
                    for i in range(1,3):
                        node = Node.objects.filter(node_id = node_id+i)
                        if node.exists():
                            node.delete()
                            delete_node_file(node_name, node_id + i, folder)

            return True, f"Node {node_id} deleted."
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            raise e  # Re-raise for the view to handle



class NodeUpdater:
    """
    ### This Class can only be called \n
    (no initialization)\n
    ## Takes: \n
    node_id: int - id for node in database \n
    paload: dict - node info \n
    return_serialized: bool - return data in serialized version (base64)
    ## Returns: \n
    success message
    """
    def __call__(
            self, 
            node_id: int, 
            payload: dict, 
            return_serialized: bool = False
            ) -> tuple:

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
                for i, f in enumerate(folders, 1):
                    config = NodeLoader()(original_id+i,from_db=True)   # returns new node's payload
                    config.pop("node_id")                               # we don't need its id

                    f_path = NodeDirectoryManager.get_nodes_dir(f)
                    # id for new node (not necessary as its id should be like old one)
                    tmp_id = original_id + i
                    # id for old node (which will be assigned to the new node)
                    new_id = node_id + i 
                    # get new node's data, as payload doesn't have it
                    data = NodeLoader()(tmp_id).get('node_data')       

                    # The following section is important
                    # it saves payload with new changes while appending its data to the original one

                    new_payload = payload.copy()
                    new_payload['node_id'] = new_id
                    new_payload['node_data'] = data
                    new_payload.update(**config)

                    # to make things clear the original node data is a combination of its parts
                    # for example train_test_split node:-
                    # original node data will be (train_data, test_data)
                    # while the train part will only take train_data, and the test part
                    # will take test_data, that's why I have appended data to the original one
                    payload['node_data'].append(data)
                    NodeSaver()(new_payload, path=f_path)
                    NodeDeleter()(tmp_id)
            
            # now we assign the old node's id for the new node so it takes same identifier

            payload['node_id'] = node_id
            NodeSaver()(payload, path=folder_path)      # ...وتوتة توتة خلصت الحدوتة الحمدلله
            NodeDeleter()(original_id, is_special_case, is_multi_channel)
            
            # this part to delete node if its name isn't same as new one's name
            if node.node_name != payload.get("node_name"):
                delete_node_file(node.node_name, node.node_id,folder)

            # serialization part

            node_data = NodeLoader()(node_id, from_db=True, return_serialized=return_serialized).get('node_data')
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