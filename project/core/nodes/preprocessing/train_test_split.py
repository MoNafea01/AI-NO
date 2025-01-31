from sklearn.model_selection import train_test_split
from ..utils import DataHandler, NodeSaver
from .utils import PayloadBuilder

class TrainTestSplit:
    def __init__(self, data, params=None):
        self.data = DataHandler.extract_data(data)
        self.params = params if params else {'test_size': 0.2, 'random_state': 42}
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = train_test_split(self.data,**self.params)
            payload1 = PayloadBuilder.build_payload("Train data", out1, "train_test_split", node_type="split")
            payload2 = PayloadBuilder.build_payload("Test data", out2, "train_test_split", node_type="split")
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
    splitter_args = {
        "data":[[0, 1, 0, 1, 0]]
    }
    splitter = TrainTestSplit(splitter_args)
    print(splitter())
