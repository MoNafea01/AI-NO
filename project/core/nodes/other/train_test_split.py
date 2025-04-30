from sklearn.model_selection import train_test_split
from ...repositories import NodeSaver, NodeDataExtractor
from ..utils import PayloadBuilder
from ..base_node import BaseNode, SAVING_DIR

class TrainTestSplit(BaseNode):
    def __init__(self, X, y, params=None, project_id: int = None, *args, **kwargs):
        err = None
        self.X, self.y = NodeDataExtractor()(X, y, project_id=project_id)
        if any(isinstance(i, str) for i in [self.X, self.y]):
            err = "Failed to load Nodes. Please check the provided IDs."

        self.params = params if params else {'test_size': 0.2, 'random_state': 42}
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self.split(err)

    def split(self, err=None):
        if err:
            return err
        try:
            out1, out2 = None, None

            if self.X is not None:
                out1 = train_test_split(self.X, **self.params)
            if self.y is not None:
                out2 = train_test_split(self.y, **self.params)

            payload = []
            payload.append(PayloadBuilder.build_payload("Data", (out1, out2), "train_test_split", node_type="splitter", task="split", project_id=self.project_id,
                                                        uid=self.uid, params=self.params))

            names = ["X_Split", "y_Split"]
            for i in range(1, 3):
                payload.append(PayloadBuilder.build_payload(f"{names[i-1]}", [out1, out2][i-1], "train_test_split", node_type="splitter", task="split", project_id=self.project_id,
                                                            uid=self.uid))

            payload[0]['children'] = [payload[1]["node_id"], payload[2]["node_id"]]
            for i in range(3):
                project_path = f"{self.project_id}/" if self.project_id else ""
                NodeSaver()(payload[i], rf"{SAVING_DIR}/{project_path}other")
                payload[i].pop("node_data", None)

            return payload
        except Exception as e:
            return f"Error splitting data: {e}"

    def __str__(self):
        return f"data: {self.payload}"

    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
            elif arg == '2':
                payload = self.payload[2]
                
        if isinstance(self.payload, str):
            payload = self.payload

        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload, project_id=self.project_id)
            payload.update({"node_data": node_data})
        return payload
