from .preprocessor import Preprocessor
from .fit import Fit
from .utils import PayloadBuilder
from ...repositories.node_repository import NodeLoader, NodeSaver


class PreprocessorTransformer:
    """Handles the transformation of data."""
    def __init__(self, preprocessor, data):
        self.preprocessor = preprocessor
        self.data = data

    def transform_data(self):
        """transform the data with the provided preprocessor."""
        try:
            output = self.preprocessor.transform(self.data)
        except Exception as e:
            raise ValueError(f"Error transforming data: {e}")
        return output


class Transform:
    """Orchestrates the transformation process."""
    def __init__(self, data, preprocessor=None, preprocessor_path=None):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        self.data = NodeLoader()(data.get("node_id")).get('node_data') if isinstance(data, dict) else data
        self.payload = self._transform()

    def _transform(self):
        if isinstance(self.preprocessor, dict):
            return self._transform_from_id()
        elif isinstance(rf"{self.preprocessor}", str):
            return self._transform_from_path()
        else:
            raise ValueError("Invalid preprocessor or path provided.")

    def _transform_from_id(self):
        try:
            prepocessor = NodeLoader()(self.preprocessor.get("node_id")).get('node_data')  # Load model using ID from database
            return self._transform_handler(prepocessor)
        except Exception as e:
            raise ValueError(f"Error transformation using preprocessor by ID: {e}")

    def _transform_from_path(self):
        try:
            prepocessor = NodeLoader()(path=self.preprocessor_path).get('node_data')
            return self._transform_handler(prepocessor)
        except Exception as e:
            raise ValueError(f"Error transformation using preprocessor by path: {e}")
    

    def _transform_handler(self, preprocessor):
        try:
            transformer = PreprocessorTransformer(preprocessor, self.data)
            output = transformer.transform_data()
            payload = PayloadBuilder.build_payload("Preprocessor transformed data", output, "transformer", task='transform', 
                                                   node_type='transformer')
            
            NodeSaver()(payload, "core/nodes/saved/data")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error transformation of data: {e}")
        
    def __str__(self):
        return str(self.payload)

    def __call__(self, *args, **kwargs):
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeLoader(return_serialized=True)(self.payload.get("node_id")).get('node_data')
            self.payload.update({"node_data": node_data})
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
    transform_args = {
        "data": [[1, 2], [2, 3]],
    }
    scaler = Preprocessor(**preprocessor_args)
    fit = Fit(**fit_args, preprocessor=scaler)
    transformed = Transform(**transform_args, preprocessor=fit)()
    print(transformed)
