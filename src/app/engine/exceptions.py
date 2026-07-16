"""Engine exception hierarchy.

All engine errors inherit from ``EngineError`` so the API layer can
catch them uniformly and map to appropriate HTTP responses.

Usage::

    from app.engine.exceptions import DataLoadError

    raise DataLoadError("dataset not found: /path/to/file.csv")

    # or in a function that returns results:
    if not os.path.exists(path):
        raise DataLoadError(f"File not found: {path}")
"""


class EngineError(Exception):
    """Base class for all engine errors."""


class NodeCreationError(EngineError):
    """Raised when a node fails to be created from params or path."""


class NodeNotFoundError(EngineError):
    """Raised when a node ID or path cannot be found."""


class DataLoadError(EngineError):
    """Raised when data loading fails (bad path, unsupported format, corrupt file)."""


class ModelFitError(EngineError):
    """Raised when model or preprocessor fitting fails."""


class PredictionError(EngineError):
    """Raised when prediction fails."""


class EvaluationError(EngineError):
    """Raised when metric evaluation fails."""


class TemplateError(EngineError):
    """Raised when template save/load fails."""


class ValidationError(EngineError):
    """Raised when node parameters are invalid.

    Maps to HTTP 422 Unprocessable Entity at the API layer.
    """

    def __init__(self, errors: list[str]):
        self.errors = errors
        super().__init__("; ".join(errors))


class PersistenceError(EngineError):
    """Raised when DB or filesystem write fails."""


class ConfigurationError(EngineError):
    """Raised when a node has invalid configuration (bad model_type, task, etc.)."""
