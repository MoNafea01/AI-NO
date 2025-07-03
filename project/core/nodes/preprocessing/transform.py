from .utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor
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
            return f"Error transforming data: {e}"
        return output


class Transform(BaseNode):
    """Orchestrates the transformation process."""
    def __init__(self, data, preprocessor=None, preprocessor_path=None, project_id=None, *args, **kwargs):
        self.preprocessor = preprocessor
        self.preprocessor_path = preprocessor_path
        err = None
        self.data = NodeDataExtractor()(data, project_id=project_id)
        if isinstance(self.data, str):
            err = "Failed to load data. Please check the provided ID."
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)

        self.payload = self._transform(err)

    def _transform(self, err=None):
        if err:
            return err
        
        if isinstance(self.preprocessor, (dict, int, str)):
            return self._transform_from_id()
        elif self.preprocessor_path and isinstance(self.preprocessor_path, str):
            return self._transform_from_path()
        else:
            return "Invalid preprocessor or path provided."

    def _transform_from_id(self):
        try:
            preprocessor = NodeDataExtractor()(self.preprocessor, project_id=self.project_id)
            if isinstance(preprocessor, str):
                return "Failed to load preprocessor. Please check the provided ID."
            return self._transform_handler(preprocessor)
        except Exception as e:
            return f"Error transformation using preprocessor by ID: {e}"

    def _transform_from_path(self):
        try:
            preprocessor = NodeDataExtractor()(self.preprocessor_path, project_id=self.project_id)
            if isinstance(preprocessor, str):
                return "Failed to load preprocessor. Please check the provided path."
            return self._transform_handler(preprocessor)
        except Exception as e:
            return f"Error transformation using preprocessor by path: {e}"
    

    def _transform_handler(self, preprocessor):
        try:
            transformer = PreprocessorTransformer(preprocessor, self.data)
            output = transformer.transform_data()
            if isinstance(output, str):
                return output
            
            payload = PayloadBuilder.build_payload("Preprocessor transformed data", output, "transformer", task='transform', 
                                                   node_type='transformer', project_id=self.project_id, uid=self.uid, input_ports=self.input_ports,
                                                   output_ports=self.output_ports, displayed_name=self.displayed_name, location_x=self.location_x, location_y=self.location_y)
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}preprocessing")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error transformation of data: {e}"
