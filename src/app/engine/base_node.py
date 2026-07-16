import logging

from .configs.const_ import SAVING_DIR
from .exceptions import EngineError, NodeCreationError, NodeNotFoundError
from .repositories.execution import EnginePersistence
from .schemas import NodePayload

logger = logging.getLogger(__name__)


def build_save_path(saving_dir: str, project_id=None, workflow_id=None) -> str:
    """Construct ``{saving_dir}/{project_id}/{workflow_id}`` skipping any ``None`` parts."""
    parts = [saving_dir]
    if project_id is not None:
        parts.append(str(project_id))
    if workflow_id is not None:
        parts.append(str(workflow_id))
    return "/".join(parts)


class BaseNode:
    """Base class for all nodes — extracts metadata from kwargs and stores remaining as params."""

    def __init__(self, **kwargs):
        self.project_id = kwargs.pop("project_id", None)
        self.workflow_id = kwargs.pop("workflow_id", None)
        self.component_id = kwargs.pop("component_id", None)
        self.displayed_name = kwargs.pop("displayed_name", "")
        self.location_x = kwargs.pop("location_x", 0.0)
        self.location_y = kwargs.pop("location_y", 0.0)

        # Port-based connections
        self.in_ports = kwargs.pop("in_ports", {}) or {}
        self.out_ports = kwargs.pop("out_ports", {}) or {}

        # Set attributes that may be read-only properties on subclasses
        for attr in ("node_id", "node_name"):
            if attr in kwargs:
                value = kwargs.pop(attr)
                # Skip if subclass defines a read-only property
                if attr in type(self).__dict__ and isinstance(type(self).__dict__[attr], property):
                    continue
                setattr(self, attr, value)

        if not hasattr(self, "params") or self.params is None:
            self.params = kwargs

        self.payload = None

    def load_node(self):
        if self.node_path:
            return self._load_from_path()
        else:
            return self._load_from_dict()

    def _load_from_dict(self):
        try:
            node = self.node_class(**self.node_params())
            if isinstance(node, str):
                raise NodeCreationError(
                    "Failed to create node. Please check the provided parameters."
                )
            return self.load_handler(node)
        except EngineError:
            raise
        except Exception as e:
            raise NodeCreationError(f"Error creating node from json: {e}") from e

    def _load_from_path(self):
        try:
            node = EnginePersistence.load_data(self.node_path, project_id=self.project_id)
            if isinstance(node, str):
                raise NodeNotFoundError("Failed to load node. Please check the provided path.")
            return self.load_handler(node)
        except EngineError:
            raise
        except Exception as e:
            raise NodeCreationError(f"Error loading node from path: {e}") from e

    def load_handler(self, node):
        try:
            payload = self.build_payload(node, **self.payload_configs())

            # Use existing node_id if set (from kwargs), otherwise keep generated one
            if hasattr(self, "node_id") and self.node_id is not None:
                payload["node_id"] = self.node_id

            # Set component_id if available
            if self.component_id is not None:
                payload["component_id"] = self.component_id

            if self.project_id:
                payload["project_id"] = self.project_id
            if self.workflow_id:
                payload["workflow_id"] = self.workflow_id

            EnginePersistence.save_result(
                payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id)
            )
            payload.pop("node_data", None)
            return payload
        except EngineError:
            raise
        except Exception as e:
            raise NodeCreationError(
                f"Error creating {getattr(self, 'node_name', '?')} node payload: {e}"
            ) from e

    def execute(self):
        raise NotImplementedError(
            f"{type(self).__name__}.execute() must be implemented by subclasses"
        )

    def node_class(self):
        raise NotImplementedError("node_class method not implemented.")

    def build_payload(self, node, message, node_name, **kwargs):
        payload = NodePayload(
            message=message,
            node_name=node_name,
            node_data=node,
            task=self.params.get("task", "general"),
            node_type=self.params.get("node_type", "general"),
            params=self.params,
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

    def node_name(self):
        raise NotImplementedError("node_name method not implemented.")

    def get_params(self):
        raise NotImplementedError("get_params method not implemented.")

    def get_folder(self):
        raise NotImplementedError("get_folder method not implemented.")

    def node_params(self, **kwargs):
        params = self.get_params()
        if kwargs:
            params.update(kwargs)
        return params

    def payload_configs(self):
        raise NotImplementedError("payload_configs method not implemented.")

    def __str__(self):
        return str(self.payload)

    def __repr__(self):
        return str(self.payload)

    def __call__(self, *args, **kwargs):
        if self.payload is None:
            self.execute()
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = EnginePersistence.load_serialized(self.payload, project_id=self.project_id)
            self.payload.update({"node_data": node_data})
        return self.payload
