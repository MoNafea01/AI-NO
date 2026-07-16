"""Base Pydantic schemas with common configuration."""

from typing import Any, Union

from pydantic import BaseModel, ConfigDict


class BaseSchema(BaseModel):
    """Base schema with common configuration."""

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
        arbitrary_types_allowed=True,
    )


# Custom type for fields that accept either JSON or int (replaces DRF JSONOrIntField)
JSONOrInt = Union[dict, list, int, str, Any]
