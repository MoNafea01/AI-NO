import numpy as np
from .model import Model
from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeLoader


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


class Fit:
    """Orchestrates the fitting process."""
    def __init__(self, X, y, model=None, model_path=None):
        self.model = model
        self.model_path = model_path
        self.X = NodeLoader()(X.get("node_id")).get('node_data') if isinstance(X, dict) else X
        self.y = NodeLoader()(y.get("node_id")).get('node_data') if isinstance(y, dict) else y
        self.payload = self._fit()

    def _fit(self):
        if isinstance(self.model, dict):
            return self._fit_from_dict()
        elif isinstance(rf"{self.model_path}", str):
            return self._fit_from_path()
        else:
            raise ValueError("Invalid model or path provided.")

    def _fit_from_dict(self):
        try:
            model = NodeLoader()(self.model.get("node_id")).get('node_data')  # Load model using ID from database
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by ID: {e}")

    def _fit_from_path(self):
        try:
            model = NodeLoader()(path=self.model_path).get('node_data')
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by path: {e}")
    

    def _fit_handler(self, model):
        try:
            fitter = ModelFitter(model, self.X, self.y)
            fitted_model = fitter.fit_model()

            payload = PayloadBuilder.build_payload("Model fitted", fitted_model, "model_fitter", node_type="fitter", task="fit_model")
            NodeSaver()(payload, "core/nodes/saved/models")
            del payload['node_data']
            return payload
        except Exception as e:
            raise ValueError(f"Error fitting model: {e}")
        
    def __str__(self):
        return str(self.payload)

    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader()(self.payload.get("node_id"),from_db=True, return_serialized=True).get('node_data')
            self.payload.update({"node_data": node_data})
        return self.payload


if __name__ == '__main__':
    # model = "C:\\Users\\a1mme\\OneDrive\\Desktop\\MO\\test_grad\\backend\\core\\nodes\\saved\\models\\linear_regression_1983596293552.pkl"
    model_args = {
        "model_name": "logistic_regression",
        "model_type": "linear_models",
        "task": "classification",
        "params": {}
    }
    fit_args = {
        "X": [[1, 2], [2, 3]],
        "y": [3, 4],
    }

    model = Model(**model_args)
    fit = Fit(**fit_args, model=model)
    print(fit)
