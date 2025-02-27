from .preprocessor import Preprocessor
from .utils import PayloadBuilder
from ..utils import NodeSaver, NodeLoader


class PreprocessorFitter:
    """Handles the fitting of preprocessors."""
    def __init__(self, preprocessor, data):
        self.preprocessor = preprocessor
        self.data = data

    def fit_preprocessor(self):
        """Fits the preprocessor with the provided data."""
        try:
            self.preprocessor.fit(self.data)
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor: {e}")
        return self.preprocessor


class Fit:
    """Orchestrates the fitting process."""
    def __init__(self, data, preprocessor=None, preprocessor_path=None):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        self.data = NodeLoader()(data.get("node_id"))[0] if isinstance(data, dict) else data
        self.payload = self._fit()

    def _fit(self):
        if isinstance(self.preprocessor, dict):
            return self._fit_from_id()
        elif isinstance(rf"{self.preprocessor_path}", str):
            return self._fit_from_path()
        else:
            raise ValueError("Invalid preprocessor or path provided.")

    def _fit_from_id(self):
        try:
            preprocessor, _ = NodeLoader()(self.preprocessor.get("node_id"))  # Load preprocessor using ID from database
            return self._fit_handler(preprocessor)
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor by ID: {e}")

    def _fit_from_path(self):
        try:
            preprocessor, _ = NodeLoader()(path=self.preprocessor_path)
            return self._fit_handler(preprocessor)
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor by path: {e}")
    

    def _fit_handler(self, preprocessor):
        try:
            fitter = PreprocessorFitter(preprocessor, self.data)
            fitted_preprocessor = fitter.fit_preprocessor()

            payload = PayloadBuilder.build_payload("Preprocessor fitted", fitted_preprocessor, "preprocessor_fitter", node_type="fitter", task="fit_preprocessor")
            NodeSaver()(payload, "core/nodes/saved/preprocessors")
            del payload['node_data']
            return payload
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor: {e}")
        
    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        return self.payload


if __name__ == '__main__':

    preprocessor_args = {
        "preprocessor_name": "standard_scaler",
        "preprocessor_type": "scaler",
        "params": {}
    }
    fit_args = {
        "data": [[1, 2], [2, 3]],
    }
    scaler = Preprocessor(**preprocessor_args)
    fit = Fit(**fit_args, preprocessor=scaler)
    print(fit)
    
