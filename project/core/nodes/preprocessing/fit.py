from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR


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


class Fit(BaseNode):
    """Orchestrates the fitting process."""
    def __init__(self, data, preprocessor=None, preprocessor_path=None, project_id=None, *args, **kwargs):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        self.data = NodeDataExtractor()(data)
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self._fit()

    def _fit(self):
        if isinstance(self.preprocessor, (dict, int)):
            return self._fit_from_id()
        elif isinstance(rf"{self.preprocessor_path}", str):
            return self._fit_from_path()
        else:
            raise ValueError("Invalid preprocessor or path provided.")

    def _fit_from_id(self):
        try:
            preprocessor = NodeDataExtractor()(self.preprocessor)
            return self._fit_handler(preprocessor)
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor by ID: {e}")

    def _fit_from_path(self):
        try:
            preprocessor = NodeDataExtractor()(self.preprocessor_path)
            return self._fit_handler(preprocessor)
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor by path: {e}")
    

    def _fit_handler(self, preprocessor):
        try:
            fitter = PreprocessorFitter(preprocessor, self.data)
            fitted_preprocessor = fitter.fit_preprocessor()

            payload = PayloadBuilder.build_payload("Preprocessor fitted", fitted_preprocessor, "preprocessor_fitter", 
                                                   node_type="fitter", task="fit_preprocessor", project_id=self.project_id,
                                                   uid=self.uid)
            
            NodeSaver()(payload, rf"{SAVING_DIR}\preprocessing")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error fitting preprocessor: {e}")
