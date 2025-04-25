from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR

class ModelPredictor(BaseNode):
    """Handles the prediction of models."""
    def __init__(self, model, X):
        self.model = model
        self.X = X

    def predict_model(self):
        """predict the output with the provided data."""
        try:
            predictions = self.model.predict(self.X)
        except Exception as e:
            raise ValueError(f"Error fitting model: {e}")
        return predictions


class Predict(BaseNode):
    """Orchestrates the predicting process."""
    def __init__(self, X, model=None, model_path=None, project_id=None, *args, **kwargs):
        self.model = model
        self.model_path = model_path
        self.X = NodeDataExtractor()(X)
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self._predict()

    def _predict(self):
        if isinstance(self.model, (dict, int)):
            return self._predict_from_id()
        elif isinstance(rf"{self.model}", str):
            return self._predict_from_path()
        else:
            raise ValueError("Invalid model or path provided.")

    def _predict_from_id(self):
        try:
            model = NodeDataExtractor()(self.model)
            return self._predict_handler(model)
        except Exception as e:
            raise ValueError(f"Error predicting using model by ID: {e}")

    def _predict_from_path(self):
        try:
            model = NodeDataExtractor()(self.model_path)
            return self._predict_handler(model)
        except Exception as e:
            raise ValueError(f"Error predicting using model by path: {e}")
    

    def _predict_handler(self, model):
        try:
            predictor = ModelPredictor(model, self.X)
            predictions = predictor.predict_model()
            payload = PayloadBuilder.build_payload("Model Predictions", predictions, "predictor", node_type="predictor", task='predict',
                                                    uid=self.uid)
            if self.project_id:
                payload['project_id'] = self.project_id
            NodeSaver()(payload, rf"{SAVING_DIR}\model")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error Predicting model: {e}")
