from typing import Optional, Any, Dict, List
from datetime import datetime
from .base import BaseSchema



# ── Project ──


class ProjectResponse(BaseSchema):
    id: int
    name: str
    description: Optional[str] = ""
    model: Optional[str] = None
    dataset: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ProjectDetailResponse(ProjectResponse):
    content: List[Any] = []

# ── Workflow ──


class WorkflowResponse(BaseSchema):
    id: int
    name: str
    description: Optional[str] = ""
    project_id: int
    current_version: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class WorkflowDetailResponse(WorkflowResponse):
    content: List[Any] = []

# ── Node ──


class NodeResponse(BaseSchema):
    id: int
    node_name: str
    message: str = "Done"
    payload: Optional[Any] = None
    params: Optional[Dict[str, Any]] = {}
    task: str = "general"
    type: str = "general"
    project_id: Optional[int] = None
    workflow_id: Optional[int] = None
    component_id: Optional[str | int] = None
    gui_meta: Optional[Dict[str, Any]] = {}
    in_ports: Optional[Dict[str, str]] = {}
    out_ports: Optional[Dict[str, str]] = {}


# ── Component ──


class ComponentResponse(BaseSchema):
    id: int
    displayed_name: str = ""
    description: str = ""
    order: int = 0
    category_name: str = ""
    category_id: Optional[int] = None
    name: str
    type: str = "general"
    task: str = "general"
    params: Optional[Any] = None
    inputs: Optional[List] = None
    outputs: Optional[List] = None
    api_call: str


# ── Generic ──


class MessageResponse(BaseSchema):
    message: str
    data: Optional[Any] = None


class TokenPairResponse(BaseSchema):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RegisterResponse(BaseSchema):
    id: int
    email: str

