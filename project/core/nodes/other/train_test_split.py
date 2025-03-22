from sklearn.model_selection import train_test_split
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..utils import PayloadBuilder
from ..base_node import BaseNode

class TrainTestSplit(BaseNode):
    def __init__(self, data, params=None, project_id: int = None):
        self.data = NodeDataExtractor()(data)
        self.params = params if params else {'test_size': 0.2, 'random_state': 42}
        self.project_id = project_id
        self.payload = self.split()

    def split(self):
        try:
            out1, out2 = train_test_split(self.data,**self.params)

            payload = []
            payload.append(PayloadBuilder.build_payload("Data", (out1, out2), "train_test_split", node_type="splitter", task="split", project_id=self.project_id))

            names = ["Train data", "Test data"]
            for i in range(1, 3):
                payload.append(PayloadBuilder.build_payload(f"{names[i-1]}", [out1, out2][i-1], "train_test_split", node_type="splitter", task="split", project_id=self.project_id))

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
