import numpy as np

from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


class ModelFitter:
    """Handles the fitting of models."""

    def __init__(self, model, X, y):
        self.model = model
        self.X = X
        self.y = y

    def fit_model(self):
        """Fits the model with the provided data."""
        try:
            self.y = np.array(self.y).ravel()
            self.model.fit(self.X, self.y)
        except Exception as e:
            return f"Error fitting model: {e}"
        return self.model


class Fit(BaseNode, ActionMixin):
    """Orchestrates the fitting process using port-based connections."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        X_ref = in_ports.get("X")
        y_ref = in_ports.get("y")
        model_ref = in_ports.get("Model")

        self.X = EnginePersistence.load_port(X_ref, self.project_id) if X_ref else None
        self.y = EnginePersistence.load_port(y_ref, self.project_id) if y_ref else None

        if any(isinstance(i, str) for i in [self.X, self.y]):
            self.payload = "Failed to load Nodes (X, y) at least one of them. Please check the provided IDs."
            return self.payload

        # Load model from port or from path
        model_path = self.params.get("model_path")
        if model_ref:
            self.model = EnginePersistence.load_port(model_ref, self.project_id)
        elif model_path:
            self.model = EnginePersistence.load_data(model_path, project_id=self.project_id)
        else:
            self.model = None

        self.payload = self._fit_handler(self.model)
        return self.payload

    def _fit_handler(self, model):
        try:
            fitter = ModelFitter(model, self.X, self.y)
            fitted_model = fitter.fit_model()
            if isinstance(fitted_model, str):
                return fitted_model

            payload = PayloadBuilder.build_payload(
                "Model fitted",
                fitted_model,
                "model_fitter",
                node_type="fitter",
                task="fit_model",
                node_id=self.node_id,
                component_id=self.component_id,
                out_ports=self.out_ports,
                in_ports=self.in_ports,
                project_id=self.project_id,
                location_x=self.location_x,
                location_y=self.location_y,
                displayed_name=self.displayed_name,
            )

            EnginePersistence.save_result(payload, build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error creating fitting payload: {e}"
