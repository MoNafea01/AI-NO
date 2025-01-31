from .utils import PayloadBuilder
from ..utils import DataHandler, NodeSaver

class Splitter:
    """
    This Class is responsible for splitting the data into two parts.\n
    to get the first part of the data, call the instance with 'out1' as an argument\n
    to get the second part of the data, call the instance with 'out2' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """

    def __init__(self, data):
        self.data = DataHandler.extract_data(data)
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = self.data
            payload1 = PayloadBuilder.build_payload("data_1", out1, "splitter", node_type="split")
            payload2 = PayloadBuilder.build_payload("data_2", out2, "splitter", node_type="split")
            NodeSaver()(payload1, "core/nodes/saved/data")
            NodeSaver()(payload2, "core/nodes/saved/data")
            # del payload1['node_data']
            # del payload2['node_data']
            return payload1, payload2
        except Exception as e:
            raise ValueError(f"Error splitting data: {e}")
    
    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args):
        payload = self.payload
        for arg in args:
            if arg == '1':
                payload = self.payload[0]
            elif arg == '2':
                payload = self.payload[1]
        return payload
    
if __name__ == "__main__":
    import numpy as np
    data = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]
    splitter = Splitter(data)
    print(splitter(''))