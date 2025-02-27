from ..utils import PayloadBuilder
from ...repositories.node_repository import NodeLoader, NodeSaver

class Joiner:
    """
    This Class is responsible for joining two datasets.\n
    to get the joined data, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, data_1, data_2):
        self.data_1 = NodeLoader()(data_1.get("node_id"))[0] if isinstance(data_1, dict) else data_1
        self.data_2 = NodeLoader()(data_2.get("node_id"))[0] if isinstance(data_2, dict) else data_2
        self.payload = self.join()
    
    def join(self):
        try:
            joined_data = (self.data_1, self.data_2)
            payload = PayloadBuilder.build_payload("joined_data", joined_data, "joiner", node_type="custom", task="join")
            NodeSaver()(payload, "core/nodes/saved/data")
            del payload['node_data']
            return payload
        except Exception as e:
            raise ValueError(f"Error joining data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args):
        return self.payload


class Splitter:
    """
    This Class is responsible for splitting the data into two parts.\n
    to get the first part of the data, call the instance with 'out1' as an argument\n
    to get the second part of the data, call the instance with 'out2' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """

    def __init__(self, data):
        self.data = NodeLoader()(data.get("node_id"))[0] if isinstance(data, dict) else data
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = self.data
            payload = PayloadBuilder.build_payload("data", (out1, out2), "splitter", node_type="custom", task="split")
            n_id = payload['node_id']
            payload1 = PayloadBuilder.build_payload("data_1", out1, "splitter", node_type="custom", task="split", node_id=n_id+1)
            payload2 = PayloadBuilder.build_payload("data_2", out2, "splitter", node_type="custom", task="split", node_id=n_id+2)
            NodeSaver()(payload, "core/nodes/saved/data")
            NodeSaver()(payload1, "core/nodes/saved/data")
            NodeSaver()(payload2, "core/nodes/saved/data")
            del payload['node_data']
            del payload1['node_data']
            del payload2['node_data']
            return payload, payload1, payload2
        except Exception as e:
            raise ValueError(f"Error splitting data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
            elif arg == '2':
                payload = self.payload[2]
        return payload