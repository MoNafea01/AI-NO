import logging

from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..schemas import NodePayload

logger = logging.getLogger(__name__)


class BaseLayer(BaseNode):
    """Base class for all layers."""

    def __init__(self, **kwargs):
        self._err = kwargs.pop("err", None)
        super().__init__(**kwargs)

    def execute(self):
        self.payload = self.load_layer(err=self._err)
        return self.payload

    def load_layer(self, err=None):
        if err:
            return err
        if not self.name:
            self.name = self.gen_name()
        if self.layer_path:
            return self._load_from_path()
        else:
            return self._load_from_dict()

    def _load_from_dict(self):
        try:
            layer = self.layer_class(**self.layer_params())
            if isinstance(layer, str):
                return "Failed to create layer. Please check the provided parameters."
            return self.load_handler(layer)
        except Exception as e:
            return f"Error creating layer from json: {e}"

    def _load_from_path(self):
        try:
            layer = EnginePersistence.load_data(self.layer_path, project_id=self.project_id)
            if isinstance(layer, str):
                return "Failed to load layer. Please check the provided path."

            return self.load_handler(layer)
        except Exception as e:
            return f"Error loading layer from path: {e}"

    def load_handler(self, layer):
        try:
            payload = self.build_payload(layer, **self.payload_configs())

            if hasattr(self, "project_id") and self.project_id:
                payload["project_id"] = self.project_id

            if hasattr(self, "node_id") and self.node_id is not None:
                payload["node_id"] = self.node_id

            EnginePersistence.save_result(
                payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id)
            )
            payload.pop("node_data", None)
            return payload

        except Exception as e:
            return f"Error creating {self.layer_name} layer payload: {e}"

    def layer_class(self):
        return NotImplementedError("layer_class method not implemented.")

    def build_payload(self, layer, message, node_name, **kwargs):
        payload = NodePayload(
            message=message,
            node_name=node_name,
            node_data=layer,
            node_type="neural_network",
            task="nn",
            params=self.get_params(),
            project_id=self.project_id,
            workflow_id=self.workflow_id,
            component_id=self.component_id,
            in_ports=self.in_ports or {},
            out_ports=self.out_ports or {},
            displayed_name=self.displayed_name or "",
            location_x=self.location_x or 0.0,
            location_y=self.location_y or 0.0,
        )
        payload_dict = payload.model_dump(exclude_none=True)
        if kwargs:
            payload_dict.update(kwargs)
        return payload_dict

    def layer_name(self):
        return super().node_name()

    def gen_name(self):
        """generate an id for the layer"""
        return NotImplementedError("gen_name method not implemented.")

    def layer_params(self, **kwargs):
        """Parameters that passed to actual layer creation"""
        return super().node_params(**kwargs)

    def load_args(self, *args, attr="node_data"):
        """Loads node_data from the given args."""
        loaded = []
        for arg in args:
            if isinstance(arg, dict):
                success, data = EnginePersistence.load_node_meta(arg.get("node_id"))
                data = data.get(attr)
                if data is not None:
                    loaded.append(data)
            else:
                loaded.append(arg)
        if len(loaded) == 1:
            loaded = loaded.pop()
        return loaded
