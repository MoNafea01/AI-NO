
from typing import Optional, Any, List
from pydantic import Field
from .base import BaseSchema, JSONOrInt, EmailStr

# ── Component Schemas ──

class ComponentCreate(BaseSchema):
    id: int
    name: str = Field(..., max_length=255)
    displayed_name: str = ""
    description: str = ""
    order: int = 0
    category_id: Optional[int] = None
    type: str = "general"
    task: str = "general"
    params: Optional[Any] = None
    inputs: Optional[List] = None
    outputs: Optional[List] = None
    api_call: str = Field(..., max_length=100)


class ComponentUpdate(BaseSchema):
    displayed_name: Optional[str] = None
    description: Optional[str] = None
    order: Optional[int] = None
    category_id: Optional[int] = None
    name: Optional[str] = None
    type: Optional[str] = None
    task: Optional[str] = None
    params: Optional[Any] = None
    inputs: Optional[List] = None
    outputs: Optional[List] = None
    api_call: Optional[str] = None


# ── Node Schemas ──
class NodeCreate(BaseSchema):
    node_name: str = Field(..., max_length=255)
    params: dict[str, Any] | None = None
    in_ports: dict[str, str] | None = None
    out_ports: dict[str, str] | None = None
    selected_output: str | None = None
    project_id: Optional[int] = None
    workflow_id: Optional[int] = None
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
    name: Optional[str] = Field(None, max_length=255)
    description: Optional[str] = None


# ── Project Schemas ──
class ProjectCreate(BaseSchema):
    name: str = Field(..., max_length=255)
    description: str = ""
    model: Optional[str] = None
    dataset: Optional[str] = None


class ProjectUpdate(BaseSchema):
    name: Optional[str] = Field(None, max_length=255)
    description: Optional[str] = None
    model: Optional[str] = None
    dataset: Optional[str] = None


class BulkProjectDelete(BaseSchema):
    ids: List[int]


class ExportProjectRequest(BaseSchema):
    project_id: int
    folder_path: Optional[str] = ""
    format: Optional[str] = Field("json", pattern="^(json|ainoprj)$")
    file_name: Optional[str] = ""
    password: Optional[str] = ""


class ImportProjectRequest(BaseSchema):
    path: str
    format: str = Field("auto", pattern="^(auto|json|ainoprj)$")
    password: Optional[str] = ""
    name: Optional[str] = ""
    description: Optional[str] = ""
    project_id: Optional[int] = None


class RegisterRequest(BaseSchema):
    email: EmailStr
    password: str


class RefreshRequest(BaseSchema):
    refresh_token: str
