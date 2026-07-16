"""Shared helpers for endpoint rewrite — registry-aware node creation."""

import logging

from fastapi import HTTPException, Request
from typing import Optional



logger = logging.getLogger(__name__)


async def create_pending_node(
    request: Request,
    node_name: str,
    body_data: dict,
    project_id: Optional[int] = None,
    workflow_id: Optional[int] = None,
) -> dict:
    """Unified node creation with registry lookup, defaults merge, and validation.

    Resolves ``component_id`` from the ``components`` table and builds
    ``gui_meta`` (displayed_name, position) so the node is immediately
    usable in the visual editor.
    """
    from app.db.sql.repositories.component import ComponentRepository
    from app.db.sql.repositories.node import NodeRepository
    from app.engine.configs.registry import resolve_node
    from app.engine.validation import validate_params

    entry = resolve_node(node_name)
    if not entry:
        raise HTTPException(status_code=404, detail=f"Unknown node: '{node_name}'")

    node_type = entry["node_type"]
    task = entry["task"]
    defaults = entry["defaults"]
    metadata = entry["metadata"]

    # Merge: defaults ← user params ← metadata
    user_params = body_data.get("params") or {}
    params = {**defaults, **user_params, **metadata}

    selected_output = body_data.get("selected_output")
    if selected_output:
        params["selected_output"] = selected_output

    # Validate
    errors = validate_params(node_type, params)
    if errors:
        raise HTTPException(status_code=400, detail="; ".join(errors))

    project_id = project_id or body_data.get("project_id")
    workflow_id = workflow_id or body_data.get("workflow_id")

    # gui_meta
    displayed_name = body_data.get("displayed_name") or node_name
    location_x = body_data.get("location_x", 0.0)
    location_y = body_data.get("location_y", 0.0)
    message = body_data.get("message", "Done")

    gui_meta = {
        "displayed_name": displayed_name,
        "location_x": float(location_x),
        "location_y": float(location_y),
    }

    # Resolve component_id from the components table, fallback to components.json
    component_id = None
    try:
        comp_repo = ComponentRepository(request.app.state.db_client)
        comp = await comp_repo.get_by_name(node_name)
        if comp:
            component_id = int(comp.id)
    except Exception:
        logger.warning("Failed to resolve component_id from DB for node_name=%s", node_name)

    if component_id is None:
        try:
            from pathlib import Path
            catalog_path = None
            current_file = Path(__file__).resolve()
            for parent in [current_file.parent] + list(current_file.parents):
                candidate = parent / "core" / "components.json"
                if candidate.exists():
                    catalog_path = candidate
                    break
            if catalog_path:
                import json
                with catalog_path.open("r", encoding="utf-8") as f:
                    catalog = json.load(f)
                for category, items in catalog.items():
                    for item in (items if isinstance(items, list) else []):
                        if isinstance(item, dict) and item.get("name") == node_name:
                            component_id = item.get("component_id")
                            break
                    if component_id is not None:
                        break
        except Exception:
            logger.warning("Failed to resolve component_id from catalog for node_name=%s", node_name)

    # Ports
    in_ports = body_data.get("in_ports") or {}
    out_ports = body_data.get("out_ports") or {}

    repo = NodeRepository(request.app.state.db_client)
    node = await repo.create(
        type=node_type,
        task=task,
        params=params,
        project_id=project_id,
        workflow_id=workflow_id,
        node_name=node_name,
        gui_meta=gui_meta,
        component_id=component_id,
        in_ports=in_ports,
        out_ports=out_ports,
        status="pending",
    )
    return {
        "id": node.id,
        "node_name": node.node_name,
        "message": message,
        "payload": node.payload,
        "params": node.params,
        "task": node.task,
        "type": node.type,
        "project_id": node.project_id,
        "workflow_id": node.workflow_id,
        "component_id": node.component_id,
        "gui_meta": node.gui_meta or {},
        "in_ports": node.in_ports or {},
        "out_ports": node.out_ports or {},
    }

