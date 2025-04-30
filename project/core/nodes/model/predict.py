from .utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor
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
            return f"Error fitting model: {e}"
        return predictions


class Predict(BaseNode):
    """Orchestrates the predicting process."""
    def __init__(self, X, model=None, model_path=None, project_id=None, *args, **kwargs):
        self.model = model
        self.model_path = model_path
        self.X = NodeDataExtractor()(X, project_id=project_id)
        err = None
        if isinstance(self.X, str):
            err = "Failed to load X. Please check the provided IDs."
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self._predict(err)

    def _predict(self, err=None):
        if err:
            return err
        if isinstance(self.model, (dict, int, str)):
            return self._predict_from_id()
        elif isinstance(rf"{self.model}", str):
            return self._predict_from_path()
        else:
            return "Invalid model or path provided."

    def _predict_from_id(self):
        try:
            model = NodeDataExtractor()(self.model, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load model. Please check the provided ID."
            return self._predict_handler(model)
        except Exception as e:
            return f"Error predicting using model by ID: {e}"

    def _predict_from_path(self):
        try:
            model = NodeDataExtractor()(self.model_path, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load model. Please check the provided path."
            if not hasattr(model, 'predict'):
                return "Model does not have a predict method. Please check the provided path."
            return self._predict_handler(model)
        except Exception as e:
            return f"Error predicting using model by path: {e}"
    

    def _predict_handler(self, model):
        try:
            predictor = ModelPredictor(model, self.X)
            predictions = predictor.predict_model()
            payload = PayloadBuilder.build_payload("Model Predictions", predictions, "predictor", node_type="predictor", task='predict',
                                                    uid=self.uid)
            if self.project_id:
                payload['project_id'] = self.project_id
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}model")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error Predicting model: {e}"
