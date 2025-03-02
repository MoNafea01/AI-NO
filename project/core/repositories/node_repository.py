import joblib
from io import BytesIO
import base64
from ai_operations.models import Node, Component
from django.core.exceptions import ObjectDoesNotExist
from ..nodes.utils import NodeDirectoryManager, NodeNameHandler, DirectoryManager
import os


class NodeSaver:
    """
    Handles saving nodes.\n
    NodeSaver()(payload, path): It saves the node to the database and path provided.\n
    payload: dict - The node payload.\n
    path: str - The path to save the node to.\n
    Returns a dictionary with the message, node_id, node_name, params, task, and node_type.
    """
    
    def __call__(self, payload, path: str = None):
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
            # print(f"Node saved to: {path}")
            joblib.dump(node, path)

        # save to database
        buffer = BytesIO()
        joblib.dump(node, buffer)
        buffer.seek(0)
        node_bytes = buffer.read()
        # node_bytes = base64.b64encode(node_bytes).decode()
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
        return {"message": f"Node {node_name} saved.",
                "node_id": node_id,
                "node_name": "node_saver",
                "params": {},
                "task": "save",
                "node_type": "saver"
                }


class NodeLoader:
    """Handles loading nodes."""
    def __call__(self, node_id=None, path=None, from_db=False, return_serialized=False, return_bytes=False) -> dict:
        if not (node_id or path):
            raise ValueError("Either node_id or path must be provided.")
        
        try:
            if isinstance(path, str):
                try:
                    node_data = joblib.load(path)
                    node_name, node_id = NodeNameHandler.handle_name(path)
                    return self.build_payload(node_data, node_name, from_db, node_id)
                except Exception as e:
                    raise ValueError(f"Error loading node from path: {e}")
            node_entry = Node.objects.get(node_id=node_id)
            node_data = node_entry.node_data
            buffer = BytesIO(node_data)
            node_name = node_entry.node_name
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
            payload.pop("created_at"), payload.pop("updated_at")
            if return_bytes: # retrieve binaries for node, it should True & from_db=True
                node_data = payload.pop("node_data")

        if return_serialized:
            if not isinstance(node_data, bytes):
                node_data = Node.objects.filter(node_id=node_id).values().first().pop("node_data")
            node_data = base64.b64encode(node_data).decode()
        payload.update({"node_data": node_data})
        return payload
        


class NodeDeleter:
    def __call__(self, node_id: str, is_special_case=False, is_multi_channel=False, from_view=False):
        """Delete a node by its ID from the database and filesystem."""
        if not node_id:
            raise ValueError("Node ID must be provided.")
        node_id = int(node_id) if node_id else None
        try:
            
            # Fetch node from database
            node = Node.objects.get(node_id=node_id)
            node_name = node.node_name
            # Delete the associated file from disk
            folder = "models" if node.task in ["regression", "classification", "fit_model"] else (
                "preprocessors" if node.task in ["preprocessing", "fit_preprocessor", "fit_transform"] else "data")
            node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{node_id}.pkl")
            if os.path.exists(node_path):
                os.remove(node_path)
            
            folders = None
            if is_multi_channel:
                folders = ['data', 'data']
            elif is_special_case:
                folders = ['preprocessors', 'data']

            if folders:
                for folder in folders:
                    for i in range(1,3):
                        node_path = os.path.join(NodeDirectoryManager.get_nodes_dir(folder), f"{node_name}_{node_id + i}.pkl")
                        if os.path.exists(node_path):
                            os.remove(node_path)
            # Delete the database entry
            node.delete()

            if from_view:
                for i in range(1,3):
                    node = Node.objects.filter(node_id=node_id + i)
                    if node.exists():
                        node.delete()

            return True, f"Node {node_id} deleted."
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            raise e  # Re-raise for the view to handle


class NodeUpdater:
    """Updates a node in the database."""
    def __call__(self, node_id, payload, return_serialized=False):
        if not node_id:
            raise ValueError("Node ID must be provided.")
        node_id = int(node_id) if node_id else None
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")
        
        try:
            is_multi_channel = False
            is_special_case = False
            node = Node.objects.get(node_id=node_id)
            multi_channel_nodes = ["data_loader", "train_test_split", "splitter"]
            special_case_nodes = ["fitter_transformer"]

            new_task = payload.get('task', node.task)
            folder = "models" if new_task in ["regression", "classification", "fit_model"] else (
                "preprocessors" if new_task in ["preprocessing", "fit_preprocessor", "fit_transform"] else "data")
            
            folder_path = NodeDirectoryManager.get_nodes_dir(folder)
            original_id = payload.get("node_id")
            
            folders = None
            if node.node_name in multi_channel_nodes:
                is_multi_channel = True
                folders = ['data', 'data']
                payload['node_data'] = []
            elif node.node_name in special_case_nodes:
                is_special_case = True
                folders = ['preprocessors', 'data']
                payload['node_data'] = []
            else:
                payload['node_data'] = NodeLoader()(original_id).get('node_data')
            if folders:
                for i, f in enumerate(folders, 1):
                    config = NodeLoader()(original_id+i,from_db=True)
                    config.pop("node_id")
                    f_path = NodeDirectoryManager.get_nodes_dir(f)
                    tmp_id = original_id + i
                    new_id = node_id + i
                    data = NodeLoader()(tmp_id).get('node_data')
                    new_payload = payload.copy()
                    new_payload['node_id'] = new_id
                    new_payload['node_data'] = data
                    new_payload.update(**config)
                    payload['node_data'].append(data)
                    NodeSaver()(new_payload, path=f_path)
                    NodeDeleter()(tmp_id)
            payload['node_id'] = node_id
            NodeSaver()(payload, path=folder_path)
            NodeDeleter()(original_id, is_special_case, is_multi_channel)
            if node.node_name != payload.get("node_name"):

                node_path = os.path.join(folder_path, f"{node.node_name}_{node_id}.pkl")
                if os.path.exists(node_path):
                    os.remove(node_path)
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

# class NodeRepository:
#     def save_node(self, payload, path: str = None):
#         return NodeSaver()(payload, path)
    
#     def load_node(self, node_id=None, path=None):
#         return NodeLoader()(node_id, path)
    
#     def delete_node(self, node_id: str, is_special_case=False, 
#                     is_multi_channel=False, from_view=False):
#         return NodeDeleter()(node_id, is_special_case, is_multi_channel, from_view)
    
#     def update_node(self, node_id, payload):
#         return NodeUpdater()(node_id, payload)
    
#     def clear_all_nodes(self, *args):
#         return ClearAllNodes()(*args)