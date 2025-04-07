from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR

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


class Transform(BaseNode):
    """Orchestrates the transformation process."""
    def __init__(self, data, preprocessor=None, preprocessor_path=None, project_id=None):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        self.data = NodeDataExtractor()(data)
        self.project_id = project_id
        self.payload = self._transform()

    def _transform(self):
        if isinstance(self.preprocessor, (dict, int)):
            return self._transform_from_id()
        elif isinstance(rf"{self.preprocessor}", str):
            return self._transform_from_path()
        else:
            raise ValueError("Invalid preprocessor or path provided.")

    def _transform_from_id(self):
        try:
            prepocessor = NodeDataExtractor()(self.preprocessor)
            return self._transform_handler(prepocessor)
        except Exception as e:
            raise ValueError(f"Error transformation using preprocessor by ID: {e}")

    def _transform_from_path(self):
        try:
            prepocessor = NodeDataExtractor()(self.preprocessor_path)
            return self._transform_handler(prepocessor)
        except Exception as e:
            raise ValueError(f"Error transformation using preprocessor by path: {e}")
    

    def _transform_handler(self, preprocessor):
        try:
            transformer = PreprocessorTransformer(preprocessor, self.data)
            output = transformer.transform_data()
            payload = PayloadBuilder.build_payload("Preprocessor transformed data", output, "transformer", task='transform', 
                                                   node_type='transformer', project_id=self.project_id)
            
            NodeSaver()(payload, rf"{SAVING_DIR}\preprocessing")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error transformation of data: {e}")
