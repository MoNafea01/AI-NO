from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


class ModelPredictor:
    """Handles the prediction of models."""

    def __init__(self, model, X):
        self.model = model
        self.X = X

    def predict_model(self):
        """predict the output with the provided data."""
        try:
            predictions = self.model.predict(self.X)
        except Exception as e:
            return f"Error predicting data: {e}"
        return predictions


class Predict(BaseNode, ActionMixin):
    """Orchestrates the predicting process using port-based connections."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        X_ref = in_ports.get("X")
        model_ref = in_ports.get("Fitted Model")

        self.X = EnginePersistence.load_port(X_ref, self.project_id) if X_ref else None
        if isinstance(self.X, str):
            self.payload = "Failed to load X. Please check the provided IDs."
            return self.payload

        # Load model from port or from path
        model_path = self.params.get("fitted_model_path") or self.params.get("model_path")
        if model_ref:
            model_obj = EnginePersistence.load_port(model_ref, self.project_id)
        elif model_path:
            model_obj = EnginePersistence.load_data(model_path, project_id=self.project_id)
        else:
            self.payload = "No model reference provided."
            return self.payload

        self.payload = self._predict_handler(model_obj)
        return self.payload

    def _predict_handler(self, model):
        try:
            predictor = ModelPredictor(model, self.X)
            predictions = predictor.predict_model()
            if isinstance(predictions, str):
                return f"Error predicting model: {predictions}"

            payload = PayloadBuilder.build_payload(
                "Model Predictions",
                predictions,
                "predictor",
                node_type="predictor",
                task="predict",
                node_id=self.node_id,
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
            return f"Error creating Prediction payload: {e}"
