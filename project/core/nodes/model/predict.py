from .model import Model
from .fit import Fit
from .utils import ModelAttributeExtractor
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

class PayloadBuilder:
    """Constructs payloads for saving and response."""
    @staticmethod
    def build_payload(message, node, data):
        print()
        return {
            "message": message,
            "params": ModelAttributeExtractor.get_attributes(node.__dict__.get("model")),
            "node_id": id(node),
            "node_name": "predict",
            "node_data": data,
        }

class Predict:
    """Orchestrates the predicting process."""
    def __init__(self, X, model=None):
        self.model = model
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
            model = NodeLoader.load(self.model.get("node_id"))  # Load model using ID from database
            return self._predict_handler(model)
        except Exception as e:
            raise ValueError(f"Error predicting using model by ID: {e}")

    def _predict_from_path(self):
        try:
            model = NodeLoader.load(path=self.model)
            return self._predict_handler(model)
        except Exception as e:
            raise ValueError(f"Error predicting using model by path: {e}")
    

    def _predict_handler(self, model):
        try:
            predictor = ModelPredictor(model, self.X)
            predictions = predictor.predict_model()
            payload = PayloadBuilder.build_payload("Model Predictions", predictor, predictions)
            NodeSaver.save(payload, "core/nodes/saved/data")
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