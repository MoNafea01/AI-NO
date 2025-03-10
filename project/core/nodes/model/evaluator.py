from ..utils import PayloadBuilder
from ..configs.metrics import METRICS as metrics
from ...repositories.node_repository import NodeLoader, NodeSaver

class Evaluator:
    def __init__(self, metric='accuracy', y_true=None, y_pred=None):
        self.y_true = NodeLoader()(y_true.get("node_id")).get('node_data') if isinstance(y_true, dict) else y_true
        self.y_pred = NodeLoader()(y_pred.get("node_id")).get('node_data') if isinstance(y_pred, dict) else y_pred
        self.metric = metric
        self.payload = self.evaluate(self.y_true, self.y_pred)

    def evaluate(self, y_true, y_pred):
        try:
            if self.metric not in metrics.keys():
                raise ValueError(f"Unsupported metric: {self.metric}")
            
            output = metrics[self.metric](y_true, y_pred)
            output = round(output,2)
            payload = PayloadBuilder.build_payload(f"{self.metric} score", output, "evaluator", node_type="metric", task="evaluate")
            NodeSaver()(payload, "core/nodes/saved/data")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error evaluating model: {e}")
    
    def __str__(self):
        return f"metric: {self.payload}"
    
    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(return_serialized=True)(self.payload.get("node_id")).get('node_data')
            self.payload.update({"node_data": node_data})
        return self.payload

if __name__ == "__main__":
    # Example usage
    import numpy as np
    y_true = np.random.randint(0, 2, 100)
    y_pred = np.random.randint(0, 2, 100)

    evaluator = Evaluator(metric='accuracy')
    score = evaluator.evaluate(y_true, y_pred)
    print(f"Score: {score}")