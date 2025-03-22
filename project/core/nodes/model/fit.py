import numpy as np
from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode


class ModelFitter:
    """Handles the fitting of models."""
    def __init__(self, model, X, y):
        self.model = model
        self.X = X
        self.y = y

    def fit_model(self):
        """Fits the model with the provided data."""
        try:
            self.y = np.array(self.y).reshape(-1, 1)
            self.model.fit(self.X, self.y)
        except Exception as e:
            raise ValueError(f"Error fitting model: {e}")
        return self.model


class Fit(BaseNode):
    """Orchestrates the fitting process."""
    def __init__(self, X, y, model=None, model_path=None, project_id=None):
        self.model = model
        self.model_path = model_path
        self.X, self.y = NodeDataExtractor()(X, y)
        self.project_id = project_id
        self.payload = self._fit()

    def _fit(self):
        if isinstance(self.model, (dict, int)):
            return self._fit_from_dict()
        elif isinstance(rf"{self.model_path}", str):
            return self._fit_from_path()
        else:
            raise ValueError("Invalid model or path provided.")

    def _fit_from_dict(self):
        try:
            model = NodeDataExtractor()(self.model)
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by ID: {e}")

    def _fit_from_path(self):
        try:
            model = NodeDataExtractor()(self.model_path)
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by path: {e}")
    

    def _fit_handler(self, model):
        try:
            fitter = ModelFitter(model, self.X, self.y)
            fitted_model = fitter.fit_model()

            payload = PayloadBuilder.build_payload("Model fitted", fitted_model, "model_fitter", node_type="fitter", task="fit_model")
            if self.project_id:
                payload['project_id'] = self.project_id

            NodeSaver()(payload, "core/nodes/saved/models")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error fitting model: {e}")
