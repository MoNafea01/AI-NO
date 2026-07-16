"""I/O endpoints (project export/import only)."""

import asyncio
import logging
import os
import json
import datetime
import tempfile
import sys
from pathlib import Path
from fastapi import APIRouter, Depends, Request, HTTPException
from fastapi.responses import Response

from app.core.auth import get_current_user

from ...schemas.request import (
    ExportProjectRequest,
    ImportProjectRequest,
)

logger = logging.getLogger(__name__)

io_router = APIRouter(prefix="/io", tags=["io"])


def _validate_path(path: str, allowed_base: str | None = None) -> str:
    """Resolve and validate a file path to prevent path traversal."""
    resolved = os.path.abspath(path)
    if allowed_base:
        allowed = os.path.abspath(allowed_base)
        if not resolved.startswith(allowed):
            raise HTTPException(status_code=400, detail="Path outside allowed directory")
    return resolved


def _resolve_converter_path() -> str:
    """Find jsonAinoConverter.py relative to project root."""
    candidates = [
        Path(__file__).resolve().parent.parent.parent.parent.parent
        / "jsonAinoConverter.py",
        (
            Path(__file__).resolve().parent.parent.parent.parent.parent.parent
            / "project" / "jsonAinoConverter.py"
        ),
    ]
    for c in candidates:
        if c.exists():
            return str(c)
    return ""


@io_router.post("/export-project")
async def export_project(
    request: Request, body: ExportProjectRequest,
    user: dict = Depends(get_current_user),
):
    """Export a project to JSON or AINOPRJ format."""
    from app.db.sql.repositories.node import NodeRepository
    from app.db.sql.repositories.project import ProjectRepository

    project_repo = ProjectRepository(request.app.state.db_client)
    node_repo = NodeRepository(request.app.state.db_client)

    project = await project_repo.get_by_id(body.project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    nodes = await node_repo.get_by_project(body.project_id)
    nodes_data = []
    for n in nodes:
        gui_meta = n.gui_meta or {}
        nodes_data.append({
            "id": n.id,
            "node_name": n.node_name,
            "message": gui_meta.get("message", "Done"),
            "payload": n.payload,
            "params": n.params,
            "task": n.task,
            "type": n.type,
            "project_id": n.project_id,
            "workflow_id": n.workflow_id,
            "component_id": n.component_id,
            "gui_meta": gui_meta,
            "in_ports": n.in_ports or {},
            "out_ports": n.out_ports or {},
        })

    export_data = {
        "project_id": body.project_id,
        "project_name": project.name,
        "project_description": project.description or "",
        "export_date": datetime.datetime.now().isoformat(),
        "model": project.model or "",
        "dataset": project.dataset or "",
        "nodes": nodes_data,
    }

    json_str = json.dumps(export_data, indent=4)
    folder_path = body.folder_path or ""
    fmt = (body.format or "json").lower()
    file_name = (body.file_name or project.name.replace(" ", "_") + "_export")
    password = body.password or ""

    if fmt == "json":
        if folder_path:
            folder_path = _validate_path(folder_path)
            os.makedirs(folder_path, exist_ok=True)
            save_path = os.path.join(folder_path, file_name + ".json")
            with open(save_path, "w", encoding="utf-8") as f:
                f.write(json_str)
            return {"message": f"Exported to {save_path}", "path": save_path}
        return Response(
            content=json_str,
            media_type="application/json",
            headers={"Content-Disposition": f"attachment; filename={file_name}.json"},
        )

    if fmt == "ainoprj":
        converter = _resolve_converter_path()
        if not converter:
            raise HTTPException(status_code=500, detail="jsonAinoConverter.py not found")

        tmp_json = tempfile.NamedTemporaryFile(suffix=".json", delete=False, mode="w")
        tmp_json.write(json_str)
        tmp_json_path = tmp_json.name
        tmp_json.close()

        if folder_path:
            folder_path = _validate_path(folder_path)
            os.makedirs(folder_path, exist_ok=True)
            out_path = os.path.join(folder_path, file_name + ".ainoprj")
        else:
            out_path = tempfile.NamedTemporaryFile(suffix=".ainoprj", delete=False).name

        encrypt = "1" if password else "0"
        try:
            cmd = [sys.executable, converter, "json", "ainoprj", tmp_json_path, out_path, encrypt]
            if password:
                cmd.append(password)
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            stdout, stderr = await process.communicate()
            if process.returncode != 0:
                raise Exception(stderr.decode())
            os.unlink(tmp_json_path)
            if folder_path:
                return {
                    "message": f"Exported to {out_path}",
                    "path": out_path,
                    "encrypted": bool(password),
                }
            with open(out_path, "rb") as f:
                content = f.read()
            os.unlink(out_path)
            return Response(
                content=content,
                media_type="application/octet-stream",
                headers={"Content-Disposition": f"attachment; filename={file_name}.ainoprj"},
            )
        except Exception as e:
            if os.path.exists(tmp_json_path):
                os.unlink(tmp_json_path)
            logger.exception("Export to ainoprj format failed")
            raise HTTPException(status_code=500, detail=f"Export failed: {e}")

    raise HTTPException(status_code=400, detail=f"Unsupported format: {fmt}")


@io_router.post("/import-project")
async def import_project(
    request: Request, body: ImportProjectRequest,
    user: dict = Depends(get_current_user),
):
    """Import a project from file."""
    from app.db.sql.repositories.node import NodeRepository
    from app.db.sql.repositories.project import ProjectRepository

    file_path = _validate_path(body.path)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail=f"File not found: {file_path}")

    fmt = body.format or "auto"
    if fmt == "auto":
        _, ext = os.path.splitext(file_path.lower())
        if ext == ".json":
            fmt = "json"
        elif ext == ".ainoprj":
            fmt = "ainoprj"
        else:
            raise HTTPException(status_code=400, detail=f"Cannot detect format for {ext}")

    password = body.password or ""
    project_name = body.name or os.path.basename(file_path).split(".")[0]
    project_description = body.description or project_name

    json_data = None
    if fmt == "json":
        with open(file_path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        json_data = raw if isinstance(raw, list) else raw.get("nodes", [])

    elif fmt == "ainoprj":
        converter = _resolve_converter_path()
        if not converter:
            raise HTTPException(status_code=500, detail="jsonAinoConverter.py not found")

        tmp_json = tempfile.NamedTemporaryFile(suffix=".json", delete=False, mode="w")
        tmp_json_path = tmp_json.name
        tmp_json.close()

        encrypt = "1" if password else "0"
        try:
            cmd = [sys.executable, converter, "ainoprj", "json", file_path, tmp_json_path, encrypt]
            if password:
                cmd.append(password)
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            stdout, stderr = await process.communicate()
            if process.returncode != 0:
                raise Exception(stderr.decode())
            with open(tmp_json_path, "r", encoding="utf-8") as f:
                raw = json.load(f)
            json_data = raw if isinstance(raw, list) else raw.get("nodes", [])
            os.unlink(tmp_json_path)
        except Exception as e:
            if os.path.exists(tmp_json_path):
                os.unlink(tmp_json_path)
            logger.exception("Import conversion from ainoprj format failed")
            raise HTTPException(status_code=500, detail=f"Import conversion failed: {e}")

    if not json_data:
        raise HTTPException(status_code=400, detail="No nodes found in import file")

    project_repo = ProjectRepository(request.app.state.db_client)
    project = (
        await project_repo.get_by_id(body.project_id)
        if body.project_id
        else None
    )
    if not project:
        project = await project_repo.create(name=project_name, description=project_description)

    node_repo = NodeRepository(request.app.state.db_client)
    for node in json_data:
        if isinstance(node, dict):
            node.pop("project", None)
            node.pop("node_data", None)
            node["project_id"] = project.id
            if "node_id" in node:
                node["id"] = node.pop("node_id")
            try:
                await node_repo.upsert_from_payload(node)
            except Exception:
                logger.warning(
                    "Failed to import node %s into project %s, skipping",
                    node.get("id"),
                    project.id,
                )

    return {
        "success": True,
        "message": f"Imported nodes into project '{project.name}'",
        "project_id": project.id,
        "project_name": project.name,
    }
