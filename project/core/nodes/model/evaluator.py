from ..utils import PayloadBuilder
from ..configs.metrics import METRICS as metrics
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode

class Evaluator(BaseNode):
    def __init__(self, metric='accuracy', y_true=None, y_pred=None, project_id=None):
        self.y_true, self.y_pred = NodeDataExtractor()(y_true, y_pred)
        self.metric = metric
        self.project_id=project_id
        self.payload = self.evaluate(self.y_true, self.y_pred)

    def evaluate(self, y_true, y_pred):
        try:
            if self.metric not in metrics.keys():
                raise ValueError(f"Unsupported metric: {self.metric}")
            
            output = metrics[self.metric](y_true, y_pred)
            output = round(output,2)
            payload = PayloadBuilder.build_payload(f"{self.metric} score", output, "evaluator", node_type="metric", task="evaluate")
            if self.project_id:
                payload['project_id'] = self.project_id
            NodeSaver()(payload, "core/nodes/saved/data")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error evaluating model: {e}")
