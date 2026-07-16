from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


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


class Transform(BaseNode, ActionMixin):
    """Orchestrates the transformation process using port-based connections."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        data_ref = in_ports.get("Data")
        preprocessor_ref = in_ports.get("Fitted Preprocessor")

        self.data = EnginePersistence.load_port(data_ref, self.project_id) if data_ref else None
        if isinstance(self.data, str):
            self.payload = "Failed to load data. Please check the provided ID."
            return self.payload

        # Load preprocessor from port or from path
        preprocessor_path = self.params.get("fitted_preprocessor_path") or self.params.get("preprocessor_path")
        if preprocessor_ref:
            preprocessor_obj = EnginePersistence.load_port(preprocessor_ref, self.project_id)
        elif preprocessor_path:
            preprocessor_obj = EnginePersistence.load_data(preprocessor_path, project_id=self.project_id)
        else:
            self.payload = "No preprocessor reference provided."
            return self.payload

        self.payload = self._transform_handler(preprocessor_obj)
        return self.payload

    def _transform_handler(self, preprocessor):
        try:
            transformer = PreprocessorTransformer(preprocessor, self.data)
            output = transformer.transform_data()
            if isinstance(output, str):
                return output

            payload = PayloadBuilder.build_payload(
                "Preprocessor transformed data",
                output,
                "transformer",
                task="transform",
                node_type="transformer",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(payload, build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error transformation of data: {e}"
