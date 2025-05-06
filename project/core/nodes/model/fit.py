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
            return f"Error fitting model: {e}"
        return self.model


class Fit(BaseNode):
    """Orchestrates the fitting process."""
    def __init__(self, X, y, model=None, model_path=None, project_id=None, *args, **kwargs):
        self.model_path = model_path
        self.X, self.y= NodeDataExtractor()(X, y, project_id=project_id)
        err = None
        if any(isinstance(i, str) for i in [self.X, self.y]):
            err = "Failed to load Nodes (X, y) at least one of them. Please check the provided IDs."
        
        self.model = model
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self._fit(err)

    def _fit(self,err=None):
        if err:
            return err
        if isinstance(self.model, (dict, int, str)):
            return self._fit_from_dict(self.model)
        
        elif self.model_path and isinstance(self.model_path, str):
            return self._fit_from_path(self.model_path)
        else:
            return "Invalid model or path provided."

    def _fit_from_dict(self, model_id):
        try:
            model = NodeDataExtractor()(model_id, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load model. Please check the provided ID."
            return self._fit_handler(model)
        except Exception as e:
            return f"Error fitting model by ID: {e}"

    def _fit_from_path(self, model_path):
        try:
            model = NodeDataExtractor()(model_path, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load model. Please check the provided path."
            return self._fit_handler(model)
        except Exception as e:
            return f"Error fitting model by path: {e}"
    

    def _fit_handler(self, model):
        try:
            fitter = ModelFitter(model, self.X, self.y)
            fitted_model = fitter.fit_model()
            if isinstance(fitted_model, str):
                return fitted_model

            payload = PayloadBuilder.build_payload("Model fitted", fitted_model, "model_fitter", node_type="fitter", task="fit_model",
                                                   uid=self.uid)
            if self.project_id:
                payload['project_id'] = self.project_id

            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}model")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error creating fitting payload: {e}"
