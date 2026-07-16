import numpy as np

from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..configs.defaults import METRICS as metrics
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


class Evaluator(BaseNode):
    def __init__(self, **kwargs):
        self.metric = kwargs.pop("metric", "accuracy")
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        model_ref = in_ports.get("Model")
        X_ref = in_ports.get("X")
        y_ref = in_ports.get("y")

        self.y = EnginePersistence.load_port(y_ref, self.project_id) if y_ref else None
        if isinstance(self.y, str):
            self.payload = f"Failed to load y. {self.y}"
            return self.payload

        # Load model from port
        if model_ref:
            model = EnginePersistence.load_port(model_ref, self.project_id)
        else:
            model = None

        # Load X from port
        self.X = EnginePersistence.load_port(X_ref, self.project_id) if X_ref else None

        err = None
        if model is None or self.y is None:
            err = "Failed to load Model or y. Please check the provided port refs."
        elif any(isinstance(i, str) for i in [model, self.X, self.y]):
            err = "Failed to load Nodes. At least one port ref returned an error."

        if err:
            self.payload = err
            return self.payload

        # Run prediction if X is provided
        try:
            y_pred = model.predict(self.X) if self.X is not None else self.y
        except Exception as e:
            self.payload = f"Error running model.predict: {e}"
            return self.payload

        self.payload = self.evaluate(self.y, y_pred)
        return self.payload

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
            output = round(output, 3)

            if isinstance(output, str):
                return f"Error calculating metric: {output}"

            payload = PayloadBuilder.build_payload(
                f"{self.metric} score",
                output,
                "evaluator",
                node_type="metric",
                task="evaluate",
                node_id=self.node_id,
                component_id=self.component_id,
                out_ports=self.out_ports,
                in_ports=self.in_ports,
                project_id=self.project_id,
                displayed_name=self.displayed_name,
                params={"metric": self.metric},
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(
                payload, build_save_path(SAVING_DIR, self.project_id, self.workflow_id)
            )
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error creating evaluation payload: {e}"
