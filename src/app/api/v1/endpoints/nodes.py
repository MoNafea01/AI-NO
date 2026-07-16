"""Node CRUD + I/O endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Request, status
from typing import Optional

from app.core.auth import get_current_user
from app.db.sql.repositories.node import NodeRepository

from ...schemas.request import (
    NodeCreate,
    NodeLoadRequest,
    NodeSaveRequest,
    NodeTemplateLoadRequest,
    NodeTemplateSaveRequest,
    NodeUpdate,
)
from ...schemas.response import MessageResponse, NodeResponse

nodes_router = APIRouter(prefix="/nodes", tags=["nodes"])


def _get_repo(request: Request) -> NodeRepository:
    return NodeRepository(request.app.state.db_client)


def _to_response(node) -> NodeResponse:
    gui_meta = node.gui_meta or {}
    return NodeResponse(
        id=node.id,
        node_name=node.node_name,
        message=gui_meta.get("message", "Done"),
        payload=node.payload,
        params=node.params,
        task=node.task,
        type=node.type,
        project_id=node.project_id,
        workflow_id=node.workflow_id,
        component_id=node.component_id,
        gui_meta=gui_meta,
        in_ports=node.in_ports or {},
        out_ports=node.out_ports or {},
    )


# ── CRUD ─────────────────────────────────────────────────────────────────

@nodes_router.get("/", response_model=list[NodeResponse])
async def list_nodes(
    request: Request,
    user: dict = Depends(get_current_user),
    project_id: Optional[int] = None,
    workflow_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 1000,
):
    repo = _get_repo(request)
    if workflow_id is not None:
        nodes = await repo.get_by_workflow(workflow_id=workflow_id, project_id=project_id, skip=skip, limit=limit)
    elif project_id is not None:
        nodes = await repo.get_by_project(project_id=project_id, skip=skip, limit=limit)
    else:
        nodes = await repo.get_all(skip=skip, limit=limit)
    return [_to_response(n) for n in nodes]


@nodes_router.post(
    "/", response_model=NodeResponse, status_code=status.HTTP_201_CREATED
)
async def create_node(
    request: Request, body: NodeCreate, 
    project_id: Optional[int] = None, workflow_id: Optional[int] = None, 
    user: dict = Depends(get_current_user)
):
    """Unified node creation — resolves type/defaults/metadata from registry."""
    from ._helpers import create_pending_node

    result = await create_pending_node(
        request, body.node_name, body.model_dump(), project_id=project_id, workflow_id=workflow_id
    )
    return result


# ── Static paths BEFORE /{node_pk} to avoid route shadowing ──

@nodes_router.delete("/clear-all", response_model=MessageResponse)
async def clear_all_nodes(
    request: Request, with_files: bool = False, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    if with_files:
        count = await repo.clear_all_with_files()
    else:
        count = await repo.clear_all()
    return MessageResponse(message=f"Cleared {count} nodes")


@nodes_router.delete("/clear-project/", response_model=MessageResponse)
async def clear_project_nodes(
    request: Request, project_id: int, with_files: bool = False, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    if with_files:
        count = await repo.clear_project_with_files(project_id)
    else:
        count = await repo.clear_project_nodes(project_id)
    return MessageResponse(message=f"Cleared {count} nodes from project {project_id}")


@nodes_router.delete("/clear-workflow/", response_model=MessageResponse)
async def clear_workflow_nodes(
    request: Request, workflow_id: int, project_id: int | None = None, with_files: bool = False, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    if with_files:
        count = await repo.clear_workflow_with_files(workflow_id, project_id)
    else:
        count = await repo.clear_workflow_nodes(workflow_id, project_id)
    return MessageResponse(message=f"Cleared {count} nodes from workflow {workflow_id}")


# ── I/O endpoints (moved from io.py) ──

@nodes_router.post("/save")
async def save_node(
    request: Request, body: NodeSaveRequest, user: dict = Depends(get_current_user)
):
    """Save a node payload to disk."""
    import asyncio
    from app.engine.repositories.execution import EnginePersistence

    payload = body.node
    path = body.params.get("node_path", "")
    project_id = request.query_params.get("project_id")

    if not path:
        return {"message": "Path is required", "error": True}

    if isinstance(payload, int):
        success, payload = await asyncio.to_thread(
            EnginePersistence.load_node_data, node_id=payload, project_id=project_id
        )
        if not success:
            return {"message": payload, "error": True}

    saved = await asyncio.to_thread(EnginePersistence.save_result, payload, path=path)
    return saved


@nodes_router.post("/load")
async def load_node(
    request: Request, body: NodeLoadRequest, user: dict = Depends(get_current_user)
):
    """Load a node from disk and create a DB record."""
    import asyncio
    from app.engine.repositories.execution import EnginePersistence

    path = body.params.get("node_path", "")
    project_id = request.query_params.get("project_id")
    return_serialized = request.query_params.get("return_serialized", "0") == "1"

    if not path:
        return {"message": "Path is required", "error": True}

    success, result = await asyncio.to_thread(
        EnginePersistence.load_node_data,
        project_id=project_id,
        path=path,
        return_serialized=return_serialized,
    )
    if not success:
        return {"message": result, "error": True}

    result["project_id"] = project_id
    saved = await asyncio.to_thread(EnginePersistence.save_result, result)
    return saved


@nodes_router.post("/save-template")
async def save_template(
    request: Request, body: NodeTemplateSaveRequest,
    user: dict = Depends(get_current_user),
):
    """Save a node as a reusable template."""
    from app.services.node_service import NodeService

    service = NodeService()
    return await service.async_execute_node("save_template", body.model_dump())


@nodes_router.post("/load-template")
async def load_template(
    request: Request, body: NodeTemplateLoadRequest,
    user: dict = Depends(get_current_user),
):
    """Load a reusable template."""
    from app.services.node_service import NodeService

    service = NodeService()
    return await service.async_execute_node("load_template", body.model_dump())


# ── Dynamic paths AFTER static paths ──

@nodes_router.get("/{node_pk}", response_model=NodeResponse)
async def get_node(request: Request, node_pk: int, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    node = await repo.get_by_id(node_pk)
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    return _to_response(node)


@nodes_router.put("/{node_pk}", response_model=NodeResponse)
async def update_node(
    request: Request, node_pk: int, body: NodeUpdate, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    kwargs = body.model_dump(exclude_unset=True)

    gui_keys = {"location_x", "location_y", "displayed_name", "message"}
    gui_updates = {k: kwargs.pop(k) for k in list(kwargs) if k in gui_keys}
    selected_output = kwargs.pop("selected_output", None)

    if gui_updates or selected_output is not None:
        node = await repo.get_by_id(node_pk)
        if not node:
            raise HTTPException(status_code=404, detail="Node not found")
        if gui_updates:
            current_gui = dict(node.gui_meta or {})
            current_gui.update(gui_updates)
            kwargs["gui_meta"] = current_gui
        if selected_output is not None:
            current_params = dict(node.params or {})
            current_params["selected_output"] = selected_output
            kwargs["params"] = current_params

    result = await repo.update(node_pk, **kwargs)
    if not result:
        raise HTTPException(status_code=404, detail="Node not found")
    return _to_response(result)


@nodes_router.delete("/{node_pk}", response_model=MessageResponse)
async def delete_node(request: Request, node_pk: int, with_files: bool = False, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    if with_files:
        deleted = await repo.delete_with_files(node_pk)
    else:
        deleted = await repo.delete(node_pk)
    if not deleted:
        raise HTTPException(status_code=404, detail="Node not found")
    return MessageResponse(message="Node deleted")
