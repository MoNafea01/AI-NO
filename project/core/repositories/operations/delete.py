from ai_operations.models import Node
from django.core.exceptions import ObjectDoesNotExist
from core.nodes.utils import delete_node


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