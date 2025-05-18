import os
from ai_operations.models import Node
from django.core.exceptions import ObjectDoesNotExist
from core.nodes.configs.const_ import PARENT_NODES, MULTI_CHANNEL_NODES
from core.repositories.operations import NodeSaver, NodeLoader, NodeDeleter
from core.repositories.node_repository import NodeDataExtractor
from core.nodes.utils import FolderHandler
from core.nodes.configs.const_ import SAVING_DIR

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

    def __call__(self, node_id: int, project_id: int, payload: dict) -> tuple:
        if not node_id:
            return False, "Node ID must be provided."
        
        node_id = int(node_id) if node_id else None
        project_id = int(project_id) if project_id else None

        if isinstance(payload, str):
            return False, payload

        if not isinstance(payload, dict):
            return False, "Payload must be a dictionary."
        
        try:
            # take the <old> node (by its id)
            node = Node.objects.get(node_id=node_id, project_id=project_id) # get node from database
            
            folder_path = None
            if node.node_data is None:
                folder_name = FolderHandler.get_folder_by_node_name(node.node_name)
                project_path = f"{project_id}/" if project_id else ""
                folder_path = os.path.join(f'{SAVING_DIR}/{project_path}', folder_name)

            if not folder_path:
                folder_path = os.path.dirname(node.node_data)
            
            original_id = payload.get("node_id") # id for new node
            is_multi_channel = payload.get("node_name") in MULTI_CHANNEL_NODES
            payload["node_data"] = NodeDataExtractor()(original_id, project_id=project_id)

            if is_multi_channel:
                payload["node_data"] = []
                configs = []

                o_ids = payload.get("children")
                new_ids = node.children

                for o_id in o_ids:
                    success, config = NodeLoader()(o_id, project_id=project_id)
                    if not success:
                        return False, f"Failed to load config for node {o_id}: {config}"
                    configs.append(config)
                
                for i, (tmp_id, new_id) in enumerate(zip(o_ids, new_ids)):
                    data = NodeDataExtractor()(tmp_id, project_id=project_id)
                    new_payload = payload.copy()
                    new_payload.update(**configs[i])
                    new_payload.update({"node_id":new_id, "node_data": data})
                    payload["node_data"].append(data)
                    NodeSaver()(new_payload, path=folder_path)
            
            # now we assign the old node's id for the new node so it takes same identifier
            payload["node_id"] = node_id
            if payload['node_name'] not in PARENT_NODES:
                payload['children'] = node.children
            

            if payload.get("node_name") in PARENT_NODES:
                payload['parent'] = node.parent

                # Compatability with old versions
                if not payload.get('parent'):
                    payload['parent'] = node.children

                # this part updates the parent node's children to get the current node
                if len(payload['parent']) == 1:
                    Node.objects.filter(node_id=payload['parent'][0], project_id=project_id).update(children=[node.node_id])
            
            if payload.get("node_name") in MULTI_CHANNEL_NODES:
                for child in payload.get("children"):
                    Node.objects.filter(node_id=child, project_id=project_id).update(parent=[node.node_id])
            
            NodeSaver()(payload, path=folder_path)
            NodeDeleter(is_multi_channel)(original_id, project_id=project_id)
            
            # this part to delete node if its name isn't same as new one's name
            if node.node_name != payload.get("node_name") and node.node_name != "node_loader":
                if node.task != "template":
                    node_path = node.node_data
                    if node_path and os.path.exists(node_path):
                        os.remove(node_path)

            # serialization part
            success, out_node = NodeLoader(return_serialized=self.return_serialized)(node_id, project_id=project_id)
            message = f"Node {out_node.get('node_name')} with id {node_id} updated."
            payload.update({"message": message, "node_data": out_node.get('node_data')})
            return True, payload
        except ObjectDoesNotExist:
            return False, f"Node {node_id} does not exist."
        except Exception as e:
            return False, f"Error updating node: {e}"
