"""Engine-level persistence layer.

``EnginePersistence`` is the single entry point for all sync persistence
during workflow execution (.pkl I/O + DB writes via a sync session).

The legacy classes (NodeSaver, NodeLoader, NodeDataExtractor, etc.) are
kept temporarily for backward compatibility during the migration but should
not be imported by new code.
"""

from .execution import EnginePersistence

__all__ = [
    "EnginePersistence",
]
