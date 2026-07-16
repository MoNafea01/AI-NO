"""Workflow endpoints — CRUD, clone, execution, snapshots, and cache invalidation.

All endpoints are scoped under ``/workflows/{project_id}`` since workflows
belong to a project.
"""

import asyncio
import uuid

from fastapi import APIRouter, Depends, HTTPException, Request

from app.core.auth import get_current_user
from app.db.sql.repositories.node import NodeRepository
from app.db.sql.repositories.snapshot import WorkflowSnapshotRepository
from app.db.sql.repositories.workflow import WorkflowRepository, WorkflowRunRepository
from app.engine.repositories.execution import EnginePersistence
from app.engine.workflow_executor import WorkflowExecutor

from ...schemas.request import WorkflowCreate, WorkflowUpdate
from ...schemas.response import MessageResponse, WorkflowDetailResponse, WorkflowResponse

workflow_router = APIRouter(prefix="/workflows", tags=["workflows"])


def _build_snapshot(node) -> dict:
    """Build a snapshot entry from a Node, excluding GUI and execution data."""
    return {
        "id": node.id,
        "node_name": node.node_name,
        "type": node.type,
        "task": node.task,
        "params": node.params or {},
        "component_id": node.component_id,
        "in_ports": node.in_ports or {},
        "out_ports": node.out_ports or {},
    }


@workflow_router.get("/runs/{run_id}")
async def get_run_status(request: Request, run_id: int, user: dict = Depends(get_current_user)):
    """Get the current status of a workflow run."""
    repo = WorkflowRunRepository(request.app.state.db_client)
    run = await repo.get_with_steps(run_id)
    if not run:
        raise HTTPException(status_code=404, detail="Run not found")
    return {
        "id": run.id,
        "workflow_id": run.workflow_id,
        "status": run.status,
        "changed_node_ids": run.changed_node_ids,
        "error": run.error,
        "steps": [
            {
                "id": s.id,
                "node_id": s.node_id,
                "node_type": s.node_type,
                "status": s.status,
                "error": s.error,
            }
            for s in (run.steps or [])
        ],
        "created_at": run.created_at.isoformat() if run.created_at else None,
        "updated_at": run.updated_at.isoformat() if run.updated_at else None,
    }


@workflow_router.get("/{project_id}/", response_model=list[WorkflowResponse])
async def list_workflows(
    request: Request, project_id: int = None, user: dict = Depends(get_current_user)
):
    """List all workflow tabs for a project."""
    repo = WorkflowRepository(request.app.state.db_client)
    workflows = await repo.get_by_project(project_id)
    return [w.__dict__ for w in workflows]


@workflow_router.post("/{project_id}/", response_model=WorkflowResponse, status_code=201)
async def create_workflow(
    request: Request,
    project_id: int,
    body: WorkflowCreate,
    user: dict = Depends(get_current_user),
):
    """Create a new workflow tab."""
    repo = WorkflowRepository(request.app.state.db_client)
    return await repo.create(project_id=project_id, name=body.name, description=body.description)


@workflow_router.get("/{project_id}/{workflow_id}", response_model=WorkflowDetailResponse)
async def get_workflow(
    request: Request,
    project_id: int,
    workflow_id: int,
    include_nodes: int = 0,
    user: dict = Depends(get_current_user),
):
    """Get workflow details including its nodes."""
    repo = WorkflowRepository(request.app.state.db_client)
    wf = await repo.get_by_id(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")

    data = WorkflowDetailResponse.model_validate(wf)

    if include_nodes:
        node_repo = NodeRepository(request.app.state.db_client)
        nodes = await node_repo.get_by_workflow(workflow_id=workflow_id, project_id=project_id)
        data.content = [n.__dict__ for n in nodes]

    return data


@workflow_router.put("/{project_id}/{workflow_id}", response_model=WorkflowResponse)
async def update_workflow(
    request: Request,
    project_id: int,
    workflow_id: int,
    body: WorkflowUpdate,
    user: dict = Depends(get_current_user),
):
    """Update workflow name/description."""
    repo = WorkflowRepository(request.app.state.db_client)
    wf = await repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")
    kwargs = {}
    if body.name is not None:
        kwargs["name"] = body.name
    if body.description is not None:
        kwargs["description"] = body.description
    if not kwargs:
        raise HTTPException(status_code=400, detail="No fields to update")
    return await repo.update(workflow_id, **kwargs)


@workflow_router.delete("/{project_id}/{workflow_id}")
async def delete_workflow(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
):
    """Delete a workflow and its associated nodes + cache entries."""
    repo = WorkflowRepository(request.app.state.db_client)
    wf = await repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")
    await asyncio.to_thread(EnginePersistence.cache_invalidate_workflow, workflow_id)
    await repo.delete(workflow_id)
    return MessageResponse(message="Workflow deleted")


@workflow_router.post("/{project_id}/{workflow_id}/clone")
async def clone_workflow(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
    body: WorkflowCreate = None,
):
    """Deep-copy a workflow with all its nodes."""
    repo = WorkflowRepository(request.app.state.db_client)
    wf = await repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")
    new_wf = await repo.clone_workflow(workflow_id, new_name=body.name)
    return {
        "id": new_wf.id,
        "project_id": new_wf.project_id,
        "name": new_wf.name,
        "description": new_wf.description,
    }


# ── Execution ──────────────────────────────────────────────────────────────


@workflow_router.post("/{project_id}/{workflow_id}/run")
async def run_workflow(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
    changed_node_ids: list[int] = [],
):
    """Execute a workflow.

    * Empty ``changed_node_ids`` → runs all pending nodes in DAG order.
    * Specific node IDs → re-runs those nodes + their downstream dependents.
    Returns the ``run_id`` immediately.  Poll ``GET /workflows/runs/{run_id}``.
    """
    executor = WorkflowExecutor()
    run_id = await executor.run_workflow(
        workflow_id=workflow_id,
        project_id=project_id,
        changed_node_ids=changed_node_ids,
        db_client=request.app.state.db_client,
    )
    return {
        "run_id": run_id,
        "workflow_id": workflow_id,
        "project_id": project_id,
        "status": "pending",
        "message": "Workflow execution started. Poll GET /workflows/runs/{run_id} for status.",
    }


@workflow_router.get("/{project_id}/{workflow_id}/runs")
async def list_runs(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
    limit: int = 50,
):
    """List all runs for a workflow."""
    repo = WorkflowRunRepository(request.app.state.db_client)
    runs = await repo.get_by_workflow(workflow_id, limit=limit)
    return [
        {
            "id": r.id,
            "status": r.status,
            "changed_node_ids": r.changed_node_ids,
            "error": r.error,
            "created_at": r.created_at.isoformat() if r.created_at else None,
        }
        for r in runs
    ]


@workflow_router.post("/{project_id}/{workflow_id}/snapshots")
async def save_snapshot(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
    label: str = None,
):
    """Save current workflow architecture as a checkpoint.

    Truncates any forward history if the current position is not the latest.
    """
    wf_repo = WorkflowRepository(request.app.state.db_client)
    wf = await wf_repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")

    node_repo = NodeRepository(request.app.state.db_client)
    nodes = await node_repo.get_by_project(project_id)
    workflow_nodes = [n for n in nodes if n.workflow_id == workflow_id]

    snapshot_data = [_build_snapshot(n) for n in workflow_nodes]

    snap_repo = WorkflowSnapshotRepository(request.app.state.db_client)
    entry = await snap_repo.create_snapshot(
        workflow_id=workflow_id,
        snapshot=snapshot_data,
        label=label,
        current_version=wf.current_version,
    )
    return {
        "id": entry.id,
        "version": entry.version,
        "label": entry.label,
        "node_count": len(snapshot_data),
        "created_at": entry.created_at.isoformat() if entry.created_at else None,
    }


@workflow_router.get("/{project_id}/{workflow_id}/snapshots")
async def list_snapshots(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
):
    """List all saved checkpoints for a workflow."""
    wf_repo = WorkflowRepository(request.app.state.db_client)
    wf = await wf_repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")

    snap_repo = WorkflowSnapshotRepository(request.app.state.db_client)
    snapshots = await snap_repo.get_by_workflow(workflow_id)
    current = wf.current_version
    return [
        {
            "id": s.id,
            "version": s.version,
            "label": s.label,
            "is_current": s.version == current,
            "node_count": len(s.snapshot) if s.snapshot else 0,
            "created_at": s.created_at.isoformat() if s.created_at else None,
        }
        for s in snapshots
    ]


@workflow_router.post("/{project_id}/{workflow_id}/snapshots/{snapshot_id}/restore")
async def restore_snapshot(
    request: Request,
    project_id: int,
    workflow_id: int,
    snapshot_id: int,
    user: dict = Depends(get_current_user),
):
    """Restore workflow to a checkpoint and update current_version."""
    wf_repo = WorkflowRepository(request.app.state.db_client)
    wf = await wf_repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")

    snap_repo = WorkflowSnapshotRepository(request.app.state.db_client)
    snap = await snap_repo.get_by_id(snapshot_id)
    if not snap or snap.workflow_id != workflow_id:
        raise HTTPException(status_code=404, detail="Snapshot not found")

    # 1. Delete all current nodes for this workflow (+ their .pkl files)
    node_repo = NodeRepository(request.app.state.db_client)
    nodes = await node_repo.get_by_project(project_id)
    workflow_nodes = [n for n in nodes if n.workflow_id == workflow_id]
    for node in workflow_nodes:
        await node_repo.delete_with_files(node.id, project_id)

    # 2. Re-create nodes from snapshot with new IDs and remapped ports
    old_to_new: dict[int, int] = {}
    for entry in snap.snapshot:
        old_id = entry["id"]
        new_id = uuid.uuid4().int & ((1 << 63) - 1)
        old_to_new[old_id] = new_id

    def _remap_ports(ports: dict | None, mapping: dict[int, int]) -> dict:
        if not ports:
            return {}
        remapped = {}
        for port_name, ref in ports.items():
            if not isinstance(ref, str):
                remapped[port_name] = ref
                continue
            parts = ref.split(":")
            if parts:
                try:
                    ref_node_id = int(parts[0])
                    if ref_node_id in mapping:
                        parts[0] = str(mapping[ref_node_id])
                except (ValueError, TypeError):
                    pass
            remapped[port_name] = ":".join(parts)
        return remapped

    for entry in snap.snapshot:
        new_id = old_to_new[entry["id"]]
        await node_repo.create(
            id=new_id,
            node_name=entry["node_name"],
            type=entry["type"],
            task=entry.get("task", "general"),
            params=entry.get("params", {}),
            project_id=project_id,
            workflow_id=workflow_id,
            component_id=entry.get("component_id"),
            in_ports=_remap_ports(entry.get("in_ports", {}), old_to_new),
            out_ports=_remap_ports(entry.get("out_ports", {}), old_to_new),
            status="pending",
        )

    # 3. Update current_version
    await wf_repo.update(workflow_id, current_version=snap.version)

    # 4. Invalidate cache for this workflow
    await asyncio.to_thread(EnginePersistence.cache_invalidate_workflow, workflow_id)

    return {
        "message": f"Restored from version {snap.version}",
        "restored_from_version": snap.version,
        "current_version": snap.version,
        "node_count": len(snap.snapshot),
    }


@workflow_router.post("/{project_id}/{workflow_id}/snapshots/undo")
async def undo_snapshot(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
):
    """Undo: restore the previous snapshot version."""
    wf_repo = WorkflowRepository(request.app.state.db_client)
    wf = await wf_repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")
    if not wf.current_version or wf.current_version <= 1:
        raise HTTPException(status_code=400, detail="Nothing to undo")

    snap_repo = WorkflowSnapshotRepository(request.app.state.db_client)
    snap = await snap_repo.get_by_version(workflow_id, wf.current_version - 1)
    if not snap:
        raise HTTPException(status_code=404, detail="Previous snapshot not found")

    return await _apply_snapshot(
        request,
        wf_repo,
        snap_repo,
        project_id,
        workflow_id,
        wf,
        snap,
    )


@workflow_router.post("/{project_id}/{workflow_id}/snapshots/redo")
async def redo_snapshot(
    request: Request,
    project_id: int,
    workflow_id: int,
    user: dict = Depends(get_current_user),
):
    """Redo: restore the next snapshot version."""
    wf_repo = WorkflowRepository(request.app.state.db_client)
    wf = await wf_repo.get(workflow_id)
    if not wf or wf.project_id != project_id:
        raise HTTPException(status_code=404, detail="Workflow not found")
    if not wf.current_version:
        raise HTTPException(status_code=400, detail="Nothing to redo")

    snap_repo = WorkflowSnapshotRepository(request.app.state.db_client)
    snap = await snap_repo.get_by_version(workflow_id, wf.current_version + 1)
    if not snap:
        raise HTTPException(status_code=400, detail="Nothing to redo")

    return await _apply_snapshot(
        request,
        wf_repo,
        snap_repo,
        project_id,
        workflow_id,
        wf,
        snap,
    )


async def _apply_snapshot(
    request,
    wf_repo,
    snap_repo,
    project_id,
    workflow_id,
    wf,
    snap,
):
    """Shared logic for restore/undo/redo: replace nodes + update current_version."""
    node_repo = NodeRepository(request.app.state.db_client)
    nodes = await node_repo.get_by_project(project_id)
    workflow_nodes = [n for n in nodes if n.workflow_id == workflow_id]
    for node in workflow_nodes:
        await node_repo.delete_with_files(node.id, project_id)

    old_to_new: dict[int, int] = {}
    for entry in snap.snapshot:
        old_id = entry["id"]
        new_id = uuid.uuid4().int & ((1 << 63) - 1)
        old_to_new[old_id] = new_id

    def _remap_ports(ports: dict | None, mapping: dict[int, int]) -> dict:
        if not ports:
            return {}
        remapped = {}
        for port_name, ref in ports.items():
            if not isinstance(ref, str):
                remapped[port_name] = ref
                continue
            parts = ref.split(":")
            if parts:
                try:
                    ref_node_id = int(parts[0])
                    if ref_node_id in mapping:
                        parts[0] = str(mapping[ref_node_id])
                except (ValueError, TypeError):
                    pass
            remapped[port_name] = ":".join(parts)
        return remapped

    for entry in snap.snapshot:
        new_id = old_to_new[entry["id"]]
        await node_repo.create(
            id=new_id,
            node_name=entry["node_name"],
            type=entry["type"],
            task=entry.get("task", "general"),
            params=entry.get("params", {}),
            project_id=project_id,
            workflow_id=workflow_id,
            component_id=entry.get("component_id"),
            in_ports=_remap_ports(entry.get("in_ports", {}), old_to_new),
            out_ports=_remap_ports(entry.get("out_ports", {}), old_to_new),
            status="pending",
        )

    await wf_repo.update(workflow_id, current_version=snap.version)

    await asyncio.to_thread(EnginePersistence.cache_invalidate_workflow, workflow_id)

    return {
        "message": f"Restored from version {snap.version}",
        "restored_from_version": snap.version,
        "current_version": snap.version,
        "node_count": len(snap.snapshot),
    }
