from ..utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDeleter, NodeDataExtractor

class Joiner:
    """
    This Class is responsible for joining two datasets.\n
    to get the joined data, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, data_1, data_2):
        self.data_1, self.data_2 = NodeDataExtractor()(data_1, data_2)
        self.payload = self.join()
    
    def join(self):
        try:
            joined_data = (self.data_1, self.data_2)
            payload = PayloadBuilder.build_payload("joined_data", joined_data, "joiner", node_type="custom", task="join")
            
            NodeSaver()(payload, "core/nodes/saved/data")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error joining data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(self.payload)
            self.payload.update({"node_data": node_data})
        return self.payload


class Splitter:
    """
    This Class is responsible for splitting the data into two parts.    
    to get the first part of the data, call the instance with 'out1' as an argument     
    to get the second part of the data, call the instance with 'out2' as an argument    
    it also accept a dictionary as an argument  
    Note that the dictionary must have a key named "data" that has a list of two elements   
    """
    def __init__(self, data):
        self.data = NodeDataExtractor()(data)
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = self.data
            payload = PayloadBuilder.build_payload("data", (out1, out2), "splitter", node_type="custom", task="split")
            payload1 = PayloadBuilder.build_payload("data_1", out1, "splitter", node_type="custom", task="split")
            payload2 = PayloadBuilder.build_payload("data_2", out2, "splitter", node_type="custom", task="split")
            
            payload['children'] = [payload1["node_id"], payload2["node_id"]]
            
            NodeSaver()(payload, "core/nodes/saved/data")
            NodeSaver()(payload1, "core/nodes/saved/data")
            NodeSaver()(payload2, "core/nodes/saved/data")
            payload.pop("node_data", None)
            del payload1["node_data"]
            del payload2["node_data"]
            return payload, payload1, payload2
        except Exception as e:
            raise ValueError(f"Error splitting data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
                NodeDeleter()(self.payload[2]["node_id"])
                NodeDeleter()(self.payload[0]["node_id"])
            elif arg == '2':
                payload = self.payload[2]
                NodeDeleter()(self.payload[1]["node_id"])
                NodeDeleter()(self.payload[0]["node_id"])
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload)
            payload.update({"node_data": node_data})
        return payload