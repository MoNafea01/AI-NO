"""Shared mixin for action nodes that resolve a resource from ID/path then act on it."""

import logging

from .exceptions import DataLoadError, EngineError, ValidationError
from .repositories.execution import EnginePersistence

logger = logging.getLogger(__name__)


class ActionMixin:
    """Mixin that provides resource resolution (by ID or path) for action nodes.

    Subclasses call ``self._resolve_resource(resource, resource_path, error_prefix)``
    to get the loaded object, then perform their specific action on it.
    """

    def _resolve_resource(self, resource, resource_path, error_prefix="resource"):
        """Load a resource from either an ID/dict reference or a filesystem path.

        Returns the loaded object on success.
        Raises DataLoadError or ValidationError on failure.
        """
        if isinstance(resource, dict | int | str):
            return self._load_by_id(resource, error_prefix)
        elif resource_path and isinstance(resource_path, str):
            return self._load_by_path(resource_path, error_prefix)
        else:
            raise ValidationError([f"Invalid {error_prefix} or path provided."])

    def _load_by_id(self, resource_id, error_prefix):
        try:
            resource = EnginePersistence.load_data(resource_id, project_id=self.project_id)
            if isinstance(resource, str):
                raise DataLoadError(f"Failed to load {error_prefix}. Check the provided ID.")
            return resource
        except EngineError:
            raise
        except Exception as e:
            raise DataLoadError(f"Error loading {error_prefix} by ID: {e}") from e

    def _load_by_path(self, path, error_prefix):
        try:
            resource = EnginePersistence.load_data(path, project_id=self.project_id)
            if isinstance(resource, str):
                raise DataLoadError(f"Failed to load {error_prefix}. Check the provided path.")
            return resource
        except EngineError:
            raise
        except Exception as e:
            raise DataLoadError(f"Error loading {error_prefix} by path: {e}") from e
