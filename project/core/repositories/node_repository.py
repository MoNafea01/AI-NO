import os
from ai_operations.models import Node, Component
from core.nodes.configs.const_ import SAVING_DIR


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
            nodes_path = SAVING_DIR + "/" + str(project_id) if project_id else SAVING_DIR
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

    def __call__(self, *args, project_id=None):
        return self.node_data_extract(*args, project_id=project_id)

    def node_data_extract(self, *args, project_id):
        from core.repositories.operations import NodeLoader
        l = []
        for arg in args:
            if isinstance(arg, dict):
                success, data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(arg.get("node_id"), project_id=project_id)
                data = data.get("node_data")
                if data is not None:
                    l.append(data)
            elif isinstance(arg, int):
                success, data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(arg, project_id=project_id)
                data = data.get("node_data")
                if data is not None:
                    l.append(data)
            elif isinstance(arg, str):
                if arg.isnumeric():
                    success, data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(int(arg), project_id=project_id)
                    data = data.get("node_data")
                else:
                    success, data = NodeLoader(from_db=False, return_serialized=self.return_serialized, return_path=self.return_path)(path=arg)
                    data = data.get("node_data")
                if data is not None:
                    l.append(data)
            else:
                l.append(arg)
        if len(l) == 1:
            l = l.pop()
    
        return l


class Repository:
    def __init__(self, from_db : bool = True, return_serialized : bool = False, return_path : bool = False, return_data : bool = False, is_multi_channel : bool = False):
        self.from_db = from_db
        self.return_serialized = return_serialized
        self.return_path = return_path
        self.return_data = return_data
        self.is_multi_channel = is_multi_channel
    
    def save(self, payload: dict, path: str = None) -> dict:
        """Saves the node to the database and filesystem."""
        from core.repositories.operations import NodeSaver

        return NodeSaver()(payload, path)
    
    def load(self, node_id: int = None, path: str = None) -> dict:
        """Loads the node from the database or filesystem."""
        from core.repositories.operations import NodeLoader
        success, data = NodeLoader(self.from_db, self.return_serialized, self.return_path)(node_id, path)
        return data
    
    def update(self, node_id: int, payload: dict) -> dict:
        """Updates the node in the database and filesystem."""
        from core.repositories.operations import NodeUpdater

        return NodeUpdater(self.return_serialized)(node_id, payload)
    
    def delete(self, node_id: int) -> dict:
        """Deletes the node from the database and filesystem."""
        from core.repositories.operations import NodeDeleter

        return NodeDeleter(self.is_multi_channel)(node_id)
    
    def clear_all(self, *args, **kwargs) -> dict:
        """Clears all nodes from the database and filesystem."""
        return ClearAllNodes()(*args, **kwargs)
    
    def extract_data(self, *args) -> dict:
        """Extracts data from the nodes."""

        return NodeDataExtractor(self.from_db, self.return_serialized, self.return_path)(*args)
