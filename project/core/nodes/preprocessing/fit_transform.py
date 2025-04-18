from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from core.nodes.configs.const_ import SAVING_DIR

class PreprocessorFitterTransformer:
    """Handles the fitting and transformation of preprocessors."""
    def __init__(self, preprocessor, data):
        self.preprocessor = preprocessor
        self.data = data

    def fit_transform_preprocessor(self):
        """Fits and transforms the preprocessor with the provided data."""
        try:
            self.preprocessor.fit(self.data)
            output = self.preprocessor.transform(self.data)
        except Exception as e:
            raise ValueError(f"Error fitting and transforming preprocessor: {e}")
        return (self.preprocessor, output)


class FitTransform:
    """Orchestrates the fitting and transformation process."""
    def __init__(self, data, preprocessor=None, preprocessor_path=None, project_id=None):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        self.data = NodeDataExtractor()(data)
        self.project_id = project_id
        self.payload = self._fit_transform()

    def _fit_transform(self):
        if isinstance(self.preprocessor, (dict, int)):
            return self._fit_transform_from_id()
        elif isinstance(rf"{self.preprocessor_path}", str):
            return self._fit_transform_from_path()
        else:
            raise ValueError("Invalid preprocessor or path provided.")

    def _fit_transform_from_id(self):
        try:
            preprocessor = NodeDataExtractor()(self.preprocessor)
            return self._fit_transform_handler(preprocessor)
        except Exception as e:
            raise ValueError(f"Error fitting and transforming preprocessor by ID: {e}")

    def _fit_transform_from_path(self):
        try:
            preprocessor = NodeDataExtractor()(self.preprocessor_path)
            return self._fit_transform_handler(preprocessor)
        except Exception as e:
            raise ValueError(f"Error fitting and transforming preprocessor by path: {e}")
    

    def _fit_transform_handler(self, preprocessor):
        try:
            fitter_transformer = PreprocessorFitterTransformer(preprocessor, self.data)
            fitted_preprocessor, output = fitter_transformer.fit_transform_preprocessor()

            payload = []
            payload.append(PayloadBuilder.build_payload("Preprocessor fitted and transformed", (fitted_preprocessor,output),
                                                         "fitter_transformer", node_type="fitter_transformer", task="fit_transform", project_id=self.project_id))
            
            names = ["Fitted Preprocessor", "Transformed Data"]
            tasks = ["fit_preprocessor", "transform"]
            for i in range(1, 3):
                payload.append(PayloadBuilder.build_payload(f"{names[i-1]}", [fitted_preprocessor, output][i-1], "fitter_transformer",
                                                             node_type="fitter_transformer", task=tasks[i-1], project_id=self.project_id))
            
            payload[0]['children'] = [payload[1]["node_id"], payload[2]["node_id"]]
            for i in range(3):
                NodeSaver()(payload[i], rf"{SAVING_DIR}\preprocessing")
                payload[i].pop("node_data", None)

            return payload
        except Exception as e:
            raise ValueError(f"Error fitting and transforming preprocessor: {e}")


    def __str__(self):
        return str(self.payload)
    
    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
            elif arg == '2':
                payload = self.payload[2]

        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload)
            payload.update({"node_data": node_data})
        return payload
