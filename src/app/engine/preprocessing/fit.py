from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


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
            return f"Error fitting preprocessor: {e}"
        return self.preprocessor


class Fit(BaseNode, ActionMixin):
    """Orchestrates the preprocessor fitting process using port-based connections."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        data_ref = in_ports.get("Data")
        preprocessor_ref = in_ports.get("Fitted Preprocessor")

        self.data = EnginePersistence.load_port(data_ref, self.project_id) if data_ref else None
        if isinstance(self.data, str):
            self.payload = "Failed to load Nodes. Please check the provided IDs."
            return self.payload

        # Load preprocessor from port or from path
        preprocessor_path = self.params.get("preprocessor_path")
        if preprocessor_ref:
            preprocessor_obj = EnginePersistence.load_port(preprocessor_ref, self.project_id)
        elif preprocessor_path:
            preprocessor_obj = EnginePersistence.load_data(preprocessor_path, project_id=self.project_id)
        else:
            self.payload = "No preprocessor reference provided."
            return self.payload

        self.payload = self._fit_handler(preprocessor_obj)
        return self.payload

    def _fit_handler(self, preprocessor):
        try:
            fitter = PreprocessorFitter(preprocessor, self.data)
            fitted_preprocessor = fitter.fit_preprocessor()
            if isinstance(fitted_preprocessor, str):
                return f"Preprocessor fitting failed. {fitted_preprocessor}"

            payload = PayloadBuilder.build_payload(
                "Preprocessor fitted",
                fitted_preprocessor,
                "preprocessor_fitter",
                node_type="fitter",
                task="fit_preprocessor",
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
            return f"Error fitting preprocessor: {e}"
