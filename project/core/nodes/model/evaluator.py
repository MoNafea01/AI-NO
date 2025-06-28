from ..utils import PayloadBuilder
from ..configs.metrics import METRICS as metrics
from ...repositories import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR
import numpy as np

class Evaluator(BaseNode):
    def __init__(self, metric='accuracy', y_true=None, y_pred=None, project_id=None, *args, **kwargs):
        self.y_true, self.y_pred = NodeDataExtractor()(y_true, y_pred, project_id=project_id)
        err = None
        if any(isinstance(i, str) for i in [self.y_true, self.y_pred]):
            err = "Failed to load Nodes (y_true, y_pred) at least one of them. Please check the provided IDs."
        
        self.metric = metric
        self.project_id=project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.evaluate(self.y_true, self.y_pred, err)

    def evaluate(self, y_true, y_pred, err=None):
        if err:
            return err
        try:
            if self.metric not in metrics.keys():
                return f"Unsupported metric: {self.metric}"
            
            if len(y_pred.shape) > 1:
                if self.metric in ["f1", "precision", "recall", "accuracy"]:
                    if y_pred.shape[1] > 1:
                        y_pred = np.argmax(y_pred, axis=1)
                    else:
                        y_pred = y_pred.flatten()
                else:
                    y_pred = y_pred.flatten()
            
            output = metrics[self.metric](y_true, y_pred)
            output = round(output,3)
            
            if isinstance(output, str):
                return f"Error calculating metric: {output}"
            
            payload = PayloadBuilder.build_payload(f"{self.metric} score", output, "evaluator", node_type="metric", task="evaluate",
                                                   uid=self.uid, output_ports=self.output_ports, input_ports=self.input_ports, project_id=self.project_id,
                                                   displayed_name=self.displayed_name, params={"metric": self.metric}, location_x=self.location_x, location_y=self.location_y)
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}model")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error creating evaluation payload: {e}"
