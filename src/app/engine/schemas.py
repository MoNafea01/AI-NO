"""Pydantic DTOs for engine node payloads and contexts."""

import uuid
from typing import Any

from pydantic import BaseModel, Field


class NodeContext(BaseModel):
    """Metadata passed to every engine node — not execution params."""

    project_id: int | None = None
    workflow_id: int | None = None
    node_id: int | None = None
    node_name: str | None = None
    in_ports: dict = Field(default_factory=dict)
    out_ports: dict = Field(default_factory=dict)
    displayed_name: str = ""
    location_x: float = 0.0
    location_y: float = 0.0


class NodePayload(BaseModel):
    """Validated structure for a saved/returned node payload."""

    message: str
    node_id: int = Field(default_factory=lambda: uuid.uuid4().int & ((1 << 63) - 1))
    node_name: str
    node_data: Any = None
    task: str = "general"
    node_type: str = "general"
    params: dict = Field(default_factory=dict)
    project_id: int | None = None
    workflow_id: int | None = None
    component_id: str | int | None = None
    in_ports: dict = Field(default_factory=dict)
    out_ports: dict = Field(default_factory=dict)
    displayed_name: str = ""
    location_x: float = 0.0
    location_y: float = 0.0

    class Config:
        arbitrary_types_allowed = True
