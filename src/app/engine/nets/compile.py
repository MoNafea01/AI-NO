from tensorflow.keras.models import Sequential

from ..action_mixin import ActionMixin
from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


class CompileModel(BaseNode, ActionMixin):
    """Compile layer for Keras models using port-based connections."""

    def __init__(self, **kwargs):
        self.loss = kwargs.pop("loss", None)
        self.optimizer = kwargs.pop("optimizer", None)
        self.metrics = kwargs.pop("metrics", None)
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        model_ref = in_ports.get("nn_model")

        if model_ref:
            model_obj = EnginePersistence.load_port(model_ref, self.project_id)
        else:
            model_path = self.params.get("model_path")
            if model_path:
                model_obj = EnginePersistence.load_data(model_path, project_id=self.project_id)
            else:
                self.payload = "No model reference provided."
                return self.payload

        self.payload = self._compile_handler(model_obj)
        return self.payload

    def _compile_handler(self, model: Sequential):
        try:
            if not all([self.loss, self.optimizer, self.metrics]):
                return "Loss, optimizer, and metrics must be provided for compilation."

            model.compile(loss=self.loss, optimizer=self.optimizer, metrics=self.metrics)
            payload = PayloadBuilder.build_payload(
                "Model Compiled",
                model,
                "model_compiler",
                task="compile",
                node_type="compiler",
                node_id=self.node_id,
                params={
                    "loss": self.loss,
                    "optimizer": self.optimizer,
                    "metrics": self.metrics,
                },
                component_id=self.component_id,
                out_ports=self.out_ports,
                in_ports=self.in_ports,
                project_id=self.project_id,
                displayed_name=self.displayed_name,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(
                payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id)
            )
            payload.pop("node_data", None)
            return payload

        except Exception as e:
            return f"Error creating compile layer payload: {e}"
