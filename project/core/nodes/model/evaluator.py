from ..utils import PayloadBuilder
from ..configs.metrics import METRICS as metrics
from ...repositories import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR
import numpy as np

class Evaluator(BaseNode):
    def __init__(self, metric='accuracy', y_true=None, y_pred=None, project_id=None, *args, **kwargs):
        self.y_true, self.y_pred = NodeDataExtractor()(y_true, y_pred)
        self.metric = metric
        self.project_id=project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self.evaluate(self.y_true, self.y_pred)

    def evaluate(self, y_true, y_pred):
        try:
            if self.metric not in metrics.keys():
                raise ValueError(f"Unsupported metric: {self.metric}")
            

            if len(y_pred.shape) > 1:
                if y_pred.shape[1] > 1:
                    y_pred = np.argmax(y_pred, axis=1)
                else:
                    y_pred = np.round(y_pred, 3).astype(int).flatten()
            
            output = metrics[self.metric](y_true, y_pred)
            output = round(output,3)
            payload = PayloadBuilder.build_payload(f"{self.metric} score", output, "evaluator", node_type="metric", task="evaluate",
                                                   uid=self.uid)
            if self.project_id:
                payload['project_id'] = self.project_id
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}model")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error evaluating model: {e}")
