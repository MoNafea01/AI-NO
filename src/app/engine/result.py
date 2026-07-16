"""Lightweight Result type for engine operations.

Used where raising exceptions is impractical (e.g. batch operations
that collect multiple errors). For most cases, prefer raising the
appropriate exception from ``app.engine.exceptions`` directly.

Usage::

    from app.engine.result import ok, fail
    from app.engine.exceptions import DataLoadError

    def load(path):
        if not os.path.exists(path):
            return fail(DataLoadError, f"File not found: {path}")
        return ok({"data": pd.read_csv(path)})
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True, slots=True)
class Ok:
    """Successful result wrapping a value."""

    value: Any

    def __bool__(self) -> bool:
        return True


@dataclass(frozen=True, slots=True)
class Err:
    """Failed result wrapping an exception instance."""

    error: Exception

    def __bool__(self) -> bool:
        return False


Result = Ok | Err


def ok(value: Any = None) -> Ok:
    """Create a successful result."""
    return Ok(value)


def fail(exc_class: type[Exception], message: str) -> Err:
    """Create a failed result from an exception class and message."""
    return Err(exc_class(message))
