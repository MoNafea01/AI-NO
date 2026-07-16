from datetime import datetime
from typing import Any

from .base import BaseSchema

# ── Project ──


class ProjectResponse(BaseSchema):
    id: int
    name: str
    description: str | None = ""
    model: str | None = None
    dataset: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None


class ProjectDetailResponse(ProjectResponse):
    content: list[Any] = []


# ── Workflow ──


class WorkflowResponse(BaseSchema):
    id: int
    name: str
    description: str | None = ""
    project_id: int
    current_version: int | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None


class WorkflowDetailResponse(WorkflowResponse):
    content: list[Any] = []


# ── Node ──


class NodeResponse(BaseSchema):
    id: int
    node_name: str
    message: str = "Done"
    payload: Any | None = None
    params: dict[str, Any] | None = {}
    task: str = "general"
    type: str = "general"
    project_id: int | None = None
    workflow_id: int | None = None
    component_id: str | int | None = None
    gui_meta: dict[str, Any] | None = {}
    in_ports: dict[str, str] | None = {}
    out_ports: dict[str, str] | None = {}


# ── Component ──


class ComponentResponse(BaseSchema):
    id: int
    displayed_name: str = ""
    description: str = ""
    order: int = 0
    category_name: str = ""
    category_id: int | None = None
    name: str
    type: str = "general"
    task: str = "general"
    params: Any | None = None
    inputs: list | None = None
    outputs: list | None = None
    api_call: str


# ── Generic ──


class MessageResponse(BaseSchema):
    message: str
    data: Any | None = None


class TokenPairResponse(BaseSchema):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RegisterResponse(BaseSchema):
    id: int
    email: str
