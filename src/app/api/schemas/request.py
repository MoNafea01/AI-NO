from typing import Any

from pydantic import Field

from .base import BaseSchema, EmailStr, JSONOrInt

# ── Component Schemas ──


class ComponentCreate(BaseSchema):
    id: int
    name: str = Field(..., max_length=255)
    displayed_name: str = ""
    description: str = ""
    order: int = 0
    category_id: int | None = None
    type: str = "general"
    task: str = "general"
    params: Any | None = None
    inputs: list | None = None
    outputs: list | None = None
    api_call: str = Field(..., max_length=100)


class ComponentUpdate(BaseSchema):
    displayed_name: str | None = None
    description: str | None = None
    order: int | None = None
    category_id: int | None = None
    name: str | None = None
    type: str | None = None
    task: str | None = None
    params: Any | None = None
    inputs: list | None = None
    outputs: list | None = None
    api_call: str | None = None


# ── Node Schemas ──
class NodeCreate(BaseSchema):
    node_name: str = Field(..., max_length=255)
    params: dict[str, Any] | None = None
    in_ports: dict[str, str] | None = None
    out_ports: dict[str, str] | None = None
    selected_output: str | None = None
    project_id: int | None = None
    workflow_id: int | None = None
    location_x: float = 0.0
    location_y: float = 0.0
    displayed_name: str | None = None
    message: str = "Done"


class NodeUpdate(BaseSchema):
    node_name: str | None = None
    params: dict[str, Any] | None = None
    in_ports: dict[str, str] | None = None
    out_ports: dict[str, str] | None = None
    selected_output: str | None = None
    location_x: float | None = None
    location_y: float | None = None
    displayed_name: str | None = None
    message: str | None = None
    gui_meta: dict[str, Any] | None = None


class NodeSaveRequest(BaseSchema):
    node: JSONOrInt
    params: dict[str, Any]
    project_id: int | None = None
    workflow_id: int | None = None


class NodeLoadRequest(BaseSchema):
    params: dict[str, Any]
    project_id: int | None = None
    workflow_id: int | None = None


class NodeTemplateSaveRequest(BaseSchema):
    node: JSONOrInt
    params: dict[str, Any]
    project_id: int | None = None
    workflow_id: int | None = None


class NodeTemplateLoadRequest(BaseSchema):
    params: dict[str, Any] = {}
    project_id: int | None = None
    workflow_id: int | None = None


# ── Workflow Schemas ──
class WorkflowCreate(BaseSchema):
    name: str = Field(..., max_length=255)
    description: str = ""


class WorkflowUpdate(BaseSchema):
    name: str | None = Field(None, max_length=255)
    description: str | None = None


# ── Project Schemas ──
class ProjectCreate(BaseSchema):
    name: str = Field(..., max_length=255)
    description: str = ""
    model: str | None = None
    dataset: str | None = None


class ProjectUpdate(BaseSchema):
    name: str | None = Field(None, max_length=255)
    description: str | None = None
    model: str | None = None
    dataset: str | None = None


class BulkProjectDelete(BaseSchema):
    ids: list[int]


class ExportProjectRequest(BaseSchema):
    project_id: int
    folder_path: str | None = ""
    format: str | None = Field("json", pattern="^(json|ainoprj)$")
    file_name: str | None = ""
    password: str | None = ""


class ImportProjectRequest(BaseSchema):
    path: str
    format: str = Field("auto", pattern="^(auto|json|ainoprj)$")
    password: str | None = ""
    name: str | None = ""
    description: str | None = ""
    project_id: int | None = None


class RegisterRequest(BaseSchema):
    email: EmailStr
    password: str


class RefreshRequest(BaseSchema):
    refresh_token: str
