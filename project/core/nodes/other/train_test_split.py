from sklearn.model_selection import train_test_split
from ...repositories.node_repository import NodeSaver, NodeLoader, NodeDeleter
from ..utils import PayloadBuilder

class TrainTestSplit:
    def __init__(self, data, params=None):
        self.data = NodeLoader()(data.get("node_id")).get('node_data') if isinstance(data, dict) else data
        self.params = params if params else {'test_size': 0.2, 'random_state': 42}
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = train_test_split(self.data,**self.params)
            payload = PayloadBuilder.build_payload("Data", (out1, out2), "train_test_split", node_type="splitter", task="split")
            payload1 = PayloadBuilder.build_payload("Train data", out1, "train_test_split", node_type="splitter", task="split")
            payload2 = PayloadBuilder.build_payload("Test data", out2, "train_test_split", node_type="splitter", task="split")

            payload['children'] = {
                "train_data": payload1['node_id'],
                "test_data": payload2['node_id']
            }
            
            NodeSaver()(payload, "core/nodes/saved/data")
            NodeSaver()(payload1, "core/nodes/saved/data")
            NodeSaver()(payload2, "core/nodes/saved/data")
            del payload1['node_data']
            del payload['node_data']
            del payload2['node_data']
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
                NodeDeleter()(self.payload[2]['node_id'])
                NodeDeleter()(self.payload[0]['node_id'])
            elif arg == '2':
                payload = self.payload[2]
                NodeDeleter()(self.payload[1]['node_id'])
                NodeDeleter()(self.payload[0]['node_id'])
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(return_serialized=True)(payload.get("node_id")).get('node_data')
            payload.update({"node_data": node_data})
        return payload


if __name__ == "__main__":
    splitter_args = {
        "data":[[0, 1, 0, 1, 0]]
    }
    splitter = TrainTestSplit(splitter_args)
    print(splitter())
