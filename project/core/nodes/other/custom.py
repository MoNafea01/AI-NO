from ..utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode


class Joiner(BaseNode):
    """
    This Class is responsible for joining two datasets.\n
    to get the joined data, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, data_1, data_2, project_id=None):
        self.data_1, self.data_2 = NodeDataExtractor()(data_1, data_2)
        self.project_id = project_id
        self.payload = self.join()
    
    def join(self):
        try:
            joined_data = (self.data_1, self.data_2)
            payload = PayloadBuilder.build_payload("joined_data", joined_data, "joiner", node_type="custom", task="join", project_id=self.project_id)
            
            NodeSaver()(payload, "core/nodes/saved/data")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error joining data: {e}")


class Splitter:
    """
    This Class is responsible for splitting the data into two parts.    
    to get the first part of the data, call the instance with 'out1' as an argument     
    to get the second part of the data, call the instance with 'out2' as an argument    
    it also accept a dictionary as an argument  
    Note that the dictionary must have a key named "data" that has a list of two elements   
    """
    def __init__(self, data, project_id=None):
        self.project_id = project_id
        self.data = NodeDataExtractor()(data)
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = self.data

            payload = []
            payload.append(PayloadBuilder.build_payload("data", (out1, out2), "splitter", node_type="custom", task="split", project_id=self.project_id))
            
            for i in range(1, 3):
                payload.append(PayloadBuilder.build_payload(f"data_{i}", [out1, out2][i-1], "splitter", node_type="custom", task="split", project_id=self.project_id))
            
            payload[0]['children'] = [payload[1]["node_id"], payload[2]["node_id"]]
            for i in range(3):
                NodeSaver()(payload[i], "core/nodes/saved/data")
                payload[i].pop("node_data", None)
            
            return payload
        except Exception as e:
            raise ValueError(f"Error splitting data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
            elif arg == '2':
                payload = self.payload[2]
        
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload)
            payload.update({"node_data": node_data})
        return payload
