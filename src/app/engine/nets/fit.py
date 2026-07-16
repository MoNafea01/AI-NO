from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


class Fit(BaseNode, ActionMixin):
    """Orchestrates the NN fitting process using port-based connections."""

    def __init__(self, **kwargs):
        self.batch_size = kwargs.pop("batch_size", 32)
        self.epochs = kwargs.pop("epochs", 10)
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        X_ref = in_ports.get("X")
        y_ref = in_ports.get("y")
        model_ref = in_ports.get("model")

        self.X = EnginePersistence.load_port(X_ref, self.project_id) if X_ref else None
        self.y = EnginePersistence.load_port(y_ref, self.project_id) if y_ref else None

        if any(isinstance(i, str) for i in [self.X, self.y]):
            self.payload = (
                "Failed to load Nodes (X, y) at least one of them. Please check the provided IDs."
            )
            return self.payload

        # Load model from port or from path
        model_path = self.params.get("model_path")
        if model_ref:
            model_obj = EnginePersistence.load_port(model_ref, self.project_id)
        elif model_path:
            model_obj = EnginePersistence.load_data(model_path, project_id=self.project_id)
        else:
            self.payload = "No model reference provided."
            return self.payload

        self.payload = self._fit_handler(model_obj)
        return self.payload

    def _fit_handler(self, model):
        try:
            model.fit(self.X, self.y, batch_size=self.batch_size, epochs=self.epochs)
            if isinstance(model, str):
                return f"Model fitting failed. {model}"

            payload = PayloadBuilder.build_payload(
                "NN fitted",
                model,
                "nn_fitter",
                node_type="fitter",
                task="fit_model",
                node_id=self.node_id,
                params={"batch_size": self.batch_size, "epochs": self.epochs},
                component_id=self.component_id,
                out_ports=self.out_ports,
                in_ports=self.in_ports,
                project_id=self.project_id,
                displayed_name=self.displayed_name,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(
                payload, build_save_path(SAVING_DIR, self.project_id, self.workflow_id)
            )
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error creating nn fitter payload: {e}"
