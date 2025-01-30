from .model import Model
from .fit import Fit
from .utils import PayloadBuilder
from ..utils import NodeLoader, NodeSaver, DataHandler


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
            raise ValueError(f"Error fitting model: {e}")
        return predictions


class Predict:
    """Orchestrates the predicting process."""
    def __init__(self, X, model=None, model_path=None):
        self.model = model
        self.model_path = model_path
        self.X = DataHandler.extract_data(X)
        self.payload = self._predict()

    def _predict(self):
        if isinstance(self.model, dict):
            return self._predict_from_id()
        elif isinstance(rf"{self.model}", str):
            return self._predict_from_path()
        else:
            raise ValueError("Invalid model or path provided.")

    def _predict_from_id(self):
        try:
            model, _ = NodeLoader()(self.model.get("node_id"))  # Load model using ID from database
            return self._predict_handler(model)
        except Exception as e:
            raise ValueError(f"Error predicting using model by ID: {e}")

    def _predict_from_path(self):
        try:
            model, _ = NodeLoader()(path=self.model_path)
            return self._predict_handler(model)
        except Exception as e:
            raise ValueError(f"Error predicting using model by path: {e}")
    

    def _predict_handler(self, model):
        try:
            predictor = ModelPredictor(model, self.X)
            predictions = predictor.predict_model()
            payload = PayloadBuilder.build_payload("Model Predictions", predictions, "predictor", task='predict')
            NodeSaver()(payload, "core/nodes/saved/data")
            return payload
        except Exception as e:
            raise ValueError(f"Error Predicting model: {e}")
        
    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        return self.payload


if __name__ == '__main__':
    
    model_args = {
        "name": "logistic_regression",
        "type": "linear_models",
        "task": "classification",
        "params": {
            "penalty": "l2",
            "C": 0.5,
        }
    }
    fit_args = {
        "data": [[1, 2], [2, 3]],
    }
    pred_args = {
        "X": [[3, 4], [4, 5]],
    }

    model = Model(**model_args)
    fit = Fit(**fit_args, model=model)
    pred = Predict(**pred_args, model=fit)
    print(pred)