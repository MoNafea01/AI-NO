from .preprocessor import Preprocessor
from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDeleter, NodeDataExtractor

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
    def __init__(self, data, preprocessor=None, preprocessor_path=None):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        self.data = NodeDataExtractor()(data)
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
            payload = PayloadBuilder.build_payload("Preprocessor fitted and transformed", (fitted_preprocessor,output), 
                                                   "fitter_transformer", node_type="fitter_transformer", task="fit_transform")
            
            payload_fitted = PayloadBuilder.build_payload("Preprocessor fitted", fitted_preprocessor, "fitter_transformer", 
                                                          node_type="fitter_transformer", task="fit_preprocessor")
            payload_data = PayloadBuilder.build_payload("Preprocessor transformed", output, "fitter_transformer", 
                                                        node_type="fitter_transformer", task="transform")
            
            payload['children'] = {
                "fitted": payload_fitted["node_id"],
                "transformed": payload_data["node_id"]
            }
            
            NodeSaver()(payload, "core/nodes/saved/preprocessors")
            NodeSaver()(payload_data, "core/nodes/saved/data")
            NodeSaver()(payload_fitted, "core/nodes/saved/preprocessors")
            del payload_data["node_data"]
            del payload_fitted["node_data"]
            payload.pop("node_data", None)
            return payload, payload_fitted, payload_data
        except Exception as e:
            raise ValueError(f"Error fitting and transforming preprocessor: {e}")


    def __str__(self):
        return str(self.payload)
    
    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
                NodeDeleter()(self.payload[2]["node_id"])
                NodeDeleter()(self.payload[0]["node_id"])
            elif arg == '2':
                payload = self.payload[2]
                NodeDeleter()(self.payload[1]["node_id"])
                NodeDeleter()(self.payload[0]["node_id"])
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload)
            payload.update({"node_data": node_data})
        return payload
    

if __name__ == '__main__':
    preprocessor_args = {
        "preprocessor_name": "standard_scaler",
        "preprocessor_type": "scaler",
        "params": {}
    }
    fit_transform_args = {
        "data": [[1, 2], [2, 3]],
    }
    scaler = Preprocessor(**preprocessor_args)
    transformed = FitTransform(**fit_transform_args, preprocessor=scaler)()
    print(transformed)