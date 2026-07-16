from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


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
            return f"Error fitting and transforming preprocessor: {e}", None
        return (self.preprocessor, output)


class FitTransform(BaseNode, ActionMixin):
    """Orchestrates the fit+transform process.

    Stores port-keyed results: {"0:0": fitted_preprocessor, "0:1": transformed_data}.
    """

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
        preprocessor_path = self.params.get("preprocessor_path")
        if preprocessor_ref:
            preprocessor_obj = EnginePersistence.load_port(preprocessor_ref, self.project_id)
        elif preprocessor_path:
            preprocessor_obj = EnginePersistence.load_data(preprocessor_path, project_id=self.project_id)
        else:
            self.payload = "No preprocessor reference provided."
            return self.payload

        self.payload = self._fit_transform_handler(preprocessor_obj)
        return self.payload

    def _fit_transform_handler(self, preprocessor):
        try:
            fitter_transformer = PreprocessorFitterTransformer(preprocessor, self.data)
            fitted_preprocessor, output = (
                fitter_transformer.fit_transform_preprocessor()
            )
            if isinstance(fitted_preprocessor, str):
                return f"Preprocessor fitting and transformation failed. {fitted_preprocessor}"

            port_data = {"0:0": fitted_preprocessor, "0:1": output}

            payload = PayloadBuilder.build_payload(
                "Preprocessor fitted and transformed",
                port_data,
                "fit_transform_preprocessor",
                node_type="fitter_transformer",
                task="fit_transform",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                location_x=self.location_x,
                location_y=self.location_y,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
            )

            EnginePersistence.save_result(payload, build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error fitting and transforming preprocessor: {e}"
