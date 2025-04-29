import numpy as np
from .utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR

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
            raise ValueError(f"Error fitting model: {e}")
        return self.model


class Fit(BaseNode):
    """Orchestrates the fitting process."""
    def __init__(self, X, y, model=None, model_path=None, project_id=None, *args, **kwargs):
        self.model = model
        self.model_path = model_path
        self.X, self.y = NodeDataExtractor()(X, y, project_id=project_id)
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self._fit()

    def _fit(self):
        if isinstance(self.model, (dict, int, str)):
            return self._fit_from_dict(self.model)
        elif isinstance(rf"{self.model_path}", str):
            return self._fit_from_path(self.model_path)
        else:
            raise ValueError("Invalid model or path provided.")

    def _fit_from_dict(self, model_id):
        try:
            model = NodeDataExtractor()(model_id, project_id=self.project_id)
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by ID: {e}")

    def _fit_from_path(self, model_path):
        try:
            model = NodeDataExtractor()(model_path, project_id=self.project_id)
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by path: {e}")
    

    def _fit_handler(self, model):
        try:
            fitter = ModelFitter(model, self.X, self.y)
            fitted_model = fitter.fit_model()

            payload = PayloadBuilder.build_payload("Model fitted", fitted_model, "model_fitter", node_type="fitter", task="fit_model",
                                                   uid=self.uid)
            if self.project_id:
                payload['project_id'] = self.project_id

            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}model")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error fitting model: {e}")
