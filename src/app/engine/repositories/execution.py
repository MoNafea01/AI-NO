"""EnginePersistence — sync persistence layer for engine execution.

Runs inside the Celery worker process. Handles .pkl file I/O and DB updates
during workflow execution. Replaces NodeSaver, NodeLoader, NodeDataExtractor
with static methods on a single class.

All methods are sync and use ``get_sync_session()`` from ``db.py``.
"""

import base64
import copy
import logging
import os
import uuid
from io import BytesIO

import joblib

from app.engine.utils import NodeNameHandler

from .db import NodeModel, get_sync_session

logger = logging.getLogger(__name__)


class EnginePersistence:
    """Sync persistence for engine execution (Celery worker)."""

    # ── Save ──────────────────────────────────────────────────────────────

    @staticmethod
    def save_result(
        o_payload: dict, path: str = None, to_db: bool = True, to_path: bool = True
    ) -> dict:
        """Save a node payload to filesystem (.pkl) and database.

        Replaces ``NodeSaver.__call__()``.

        :param o_payload: Full node payload dict (node_id, node_name, node_data, ...).
        :param path: Directory to save .pkl file to.
        :param to_db: Whether to upsert the DB record.
        :param to_path: Whether to write .pkl to disk.
        :returns: Result dict with saved metadata.
        """
        payload = copy.deepcopy(o_payload)
        if not isinstance(payload, dict):
            raise ValueError("Payload must be a dictionary.")

        message = payload.get("message", "Done")
        node_id = payload.get("node_id")
        node_name = payload.get("node_name")
        params = payload.get("params", {})
        node = payload.get("node_data")
        task = payload.get("task", "general")
        node_type = payload.get("node_type", "general")
        workflow_id = payload.get("workflow_id")
        component_id = payload.get("component_id")
        project_id = payload.get("project_id")
        location_x = payload.get("location_x", 0.0)
        location_y = payload.get("location_y", 0.0)
        in_ports = payload.get("in_ports") or {}
        out_ports = payload.get("out_ports") or {}
        displayed_name = payload.get("displayed_name", "default")

        # ── Save to file system ──
        save_path = None
        if path and to_path:
            save_path = rf"{path}/{node_name}_{node_id}.pkl"
            if task == "save_template":
                save_path = rf"{path}/{node_name}.pkl"
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            joblib.dump(node, save_path)

        if save_path:
            save_path = os.path.abspath(save_path)

        # ── Save to database ──
        if to_db and node_id and project_id:
            with get_sync_session() as session:
                existing = (
                    session.query(NodeModel).filter_by(id=node_id, project_id=project_id).first()
                )
                payload_content = {"message": message, "node_data": save_path}
                gui_meta = {
                    "location_x": location_x,
                    "location_y": location_y,
                    "displayed_name": displayed_name,
                }
                if existing:
                    existing.node_name = node_name
                    existing.payload = payload_content
                    existing.params = params
                    existing.task = task
                    existing.type = node_type
                    existing.out_ports = out_ports
                    existing.in_ports = in_ports
                    existing.gui_meta = gui_meta
                    if workflow_id is not None:
                        existing.workflow_id = workflow_id
                    if component_id is not None:
                        existing.component_id = component_id
                else:
                    new_node = NodeModel(
                        id=node_id,
                        node_name=node_name,
                        payload=payload_content,
                        params=params,
                        task=task,
                        type=node_type,
                        project_id=project_id,
                        workflow_id=workflow_id,
                        component_id=component_id,
                        out_ports=out_ports,
                        in_ports=in_ports,
                        gui_meta=gui_meta,
                    )
                    session.add(new_node)
                session.commit()

        return {
            "message": f"Node {node_name} saved.",
            "node_id": node_id,
            "node_name": "node_saver",
            "node_data": save_path,
            "params": {},
            "task": "save",
            "node_type": "saver",
            "project_id": project_id,
            "component_id": component_id,
            "location_x": location_x,
            "location_y": location_y,
            "in_ports": in_ports,
            "out_ports": out_ports,
            "displayed_name": displayed_name,
        }

    # ── Load data (deserialized .pkl) ────────────────────────────────────

    @staticmethod
    def load_data(*args, project_id=None):
        """Load deserialized node data from one or more references.

        Replaces ``NodeDataExtractor()(*args, project_id=project_id)``.

        Accepts int (node_id), dict (with ``node_id`` key), or str (file path).
        Returns a single value if one arg, or a list if multiple args.
        """
        results = []
        for arg in args:
            if isinstance(arg, dict):
                node_id = arg.get("node_id")
                data = EnginePersistence._load_data_by_id(node_id, project_id)
                results.append(data if data is not None else "Node not found.")
            elif isinstance(arg, int):
                data = EnginePersistence._load_data_by_id(arg, project_id)
                results.append(data if data is not None else "Node not found.")
            elif isinstance(arg, str):
                if arg.isnumeric():
                    data = EnginePersistence._load_data_by_id(int(arg), project_id)
                else:
                    data = EnginePersistence._load_data_by_path(arg)
                results.append(data if data is not None else "Node not found.")
            else:
                results.append(arg)

        if len(results) == 1:
            return results[0]
        return results

    @staticmethod
    def _load_data_by_id(node_id: int, project_id: int = None):
        """Load deserialized .pkl data by node ID."""
        try:
            with get_sync_session() as session:
                entry = (
                    session.query(NodeModel).filter_by(id=node_id, project_id=project_id).first()
                )
                if not entry:
                    return None
                pld = entry.payload or {}
                node_path = pld.get("node_data")
                if node_path and os.path.exists(str(node_path)):
                    return joblib.load(node_path)
                return None
        except Exception:
            return None

    @staticmethod
    def _load_data_by_path(path: str):
        """Load deserialized .pkl data from a file path."""
        try:
            if path and os.path.exists(str(path)):
                return joblib.load(path)
            return None
        except Exception:
            return None

    # ── Load node metadata (no .pkl) ─────────────────────────────────────

    @staticmethod
    def load_node_meta(node_id, project_id=None) -> tuple:
        """Load node metadata dict from DB (no .pkl deserialization).

        Replaces ``NodeLoader()(node_id, project_id=project_id)``.

        :returns: (True, payload_dict) or (False, error_message).
        """
        if not str(node_id).isdigit():
            return False, "node_id must be an integer."

        node_id = int(node_id)
        project_id = int(project_id) if project_id else None

        try:
            with get_sync_session() as session:
                entry = (
                    session.query(NodeModel).filter_by(id=node_id, project_id=project_id).first()
                )
                if not entry:
                    return False, f"Node {node_id} not found in project {project_id}."

                gui = entry.gui_meta or {}
                pld = entry.payload or {}
                payload = {
                    "node_id": entry.id,
                    "node_name": entry.node_name,
                    "params": entry.params or {},
                    "task": entry.task or "general",
                    "node_type": entry.type or "general",
                    "project_id": entry.project_id,
                    "message": pld.get("message", ""),
                    "component_id": gui.get("component_id"),
                    "location_x": gui.get("location_x", 0.0),
                    "location_y": gui.get("location_y", 0.0),
                    "displayed_name": gui.get("displayed_name", ""),
                    "in_ports": entry.in_ports or {},
                    "out_ports": entry.out_ports or {},
                }
                return True, payload

        except Exception as e:
            return False, f"Error loading node: {e}"

    # ── Load node data (metadata + deserialized .pkl) ────────────────────

    @staticmethod
    def load_node_data(
        node_id=None,
        project_id=None,
        path=None,
        return_serialized=False,
        return_path=False,
    ) -> tuple:
        """Load full node payload: metadata from DB + deserialized .pkl.

        Replaces ``NodeLoader(from_db=True/False)(...)``.

        :returns: (True, payload_dict) or (False, error_message).
        """
        node_id = int(node_id) if node_id else None
        project_id = int(project_id) if project_id else None

        if not (node_id or path):
            return False, "Either (node_id and project_id) or path must be provided."

        try:
            # ── Load from path ──
            if path:
                try:
                    node_data = joblib.load(path)
                    node_name, nid = NodeNameHandler.handle_name(path)
                    payload = EnginePersistence._build_path_payload(
                        node_data, node_name, nid, project_id, path
                    )
                    return True, payload
                except Exception as e:
                    return False, f"Error loading node from path: {e}"

            # ── Load from database ──
            with get_sync_session() as session:
                entry = (
                    session.query(NodeModel).filter_by(id=node_id, project_id=project_id).first()
                )
                if not entry:
                    return False, f"Node {node_id} not found in project {project_id}."

                gui = entry.gui_meta or {}
                pld = entry.payload or {}
                node_path = pld.get("node_data")
                node_data = None
                try:
                    if node_path and os.path.exists(node_path):
                        node_data = joblib.load(node_path)
                except Exception as e:
                    return False, f"Error loading node data: {e}"

                payload = {
                    "node_id": entry.id,
                    "node_name": entry.node_name,
                    "params": entry.params or {},
                    "task": entry.task or "general",
                    "node_type": entry.type or "general",
                    "project_id": entry.project_id,
                    "message": pld.get("message", ""),
                    "component_id": gui.get("component_id"),
                    "location_x": gui.get("location_x", 0.0),
                    "location_y": gui.get("location_y", 0.0),
                    "displayed_name": gui.get("displayed_name", ""),
                    "in_ports": entry.in_ports or {},
                    "out_ports": entry.out_ports or {},
                }

                if return_path:
                    node_data = node_path

                if return_serialized:
                    if node_path and os.path.exists(str(node_path)):
                        with open(node_path, "rb") as f:
                            raw = f.read()
                    else:
                        buf = BytesIO()
                        joblib.dump(node_data, buf)
                        buf.seek(0)
                        raw = buf.read()
                    node_data = base64.b64encode(raw).decode()

                payload["node_data"] = node_data
                return True, payload

        except Exception as e:
            return False, f"Error loading node: {e}"

    @staticmethod
    def _build_path_payload(node_data, name, node_id, project_id, path):
        """Build a payload dict when loading from a file path."""
        return {
            "message": f"Node Loaded: {name}",
            "node_name": "node_loader",
            "node_id": uuid.uuid4().int & ((1 << 63) - 1),
            "node_data": node_data,
            "params": {},
            "task": "load_node",
            "node_type": "loader",
            "project_id": project_id,
            "in_ports": {},
            "out_ports": {},
        }

    # ── Serialize for output ──────────────────────────────────────────────

    @staticmethod
    def load_serialized(payload: dict, project_id: int = None) -> str:
        """Re-serialize payload node_data to base64 string.

        Replaces ``NodeDataExtractor(return_serialized=True)(payload, ...)``.
        """
        if isinstance(payload, dict):
            node_data = payload.get("node_data")
        else:
            node_data = payload

        if node_data is None:
            return None

        buf = BytesIO()
        joblib.dump(node_data, buf)
        buf.seek(0)
        raw = buf.read()
        return base64.b64encode(raw).decode()

    # ── Port-based data loading ──────────────────────────────────────────

    @staticmethod
    def load_port(port_ref: str, project_id: int = None):
        """Parse 'node_id:group_idx:port_idx' and load the specific output.

        For single-output nodes, returns the result as-is (no group/port extraction).
        For multi-output nodes, extracts result["group_idx:port_idx"].
        """
        if not port_ref:
            return None

        parts = str(port_ref).split(":")
        node_id = int(parts[0])
        group_idx = int(parts[1]) if len(parts) > 1 else None
        port_idx = int(parts[2]) if len(parts) > 2 else None

        success, payload = EnginePersistence.load_node_data(node_id=node_id, project_id=project_id)
        if not success:
            return f"Failed to load port {port_ref}: {payload}"

        data = payload.get("node_data") if isinstance(payload, dict) else payload

        if group_idx is not None and port_idx is not None:
            key = f"{group_idx}:{port_idx}"
            if isinstance(data, dict) and key in data:
                return data[key]
            # Single-output fallback
            return data

        return data

    # ── Helpers ───────────────────────────────────────────────────────────

    @staticmethod
    def delete_node_files(node_id: int, project_id: int = None):
        """Delete .pkl files for a node."""
        try:
            with get_sync_session() as session:
                node = session.query(NodeModel).filter_by(id=node_id, project_id=project_id).first()
                if node:
                    pld = node.payload or {}
                    node_path = pld.get("node_data")
                    if node_path and os.path.exists(node_path):
                        os.remove(node_path)
        except Exception:
            pass

    # ── Execution Cache ──────────────────────────────────────────────────

    @staticmethod
    def cache_lookup(project_id: int, node_hash: str) -> dict | None:
        """Look up cached result by project + hash. Returns result dict or None."""
        from app.db.sql.repositories.execution_cache import ExecutionCacheRepository

        return ExecutionCacheRepository.sync_lookup(project_id, node_hash)

    @staticmethod
    def cache_store(
        project_id: int,
        node_id: int,
        node_hash: str,
        result: dict,
        workflow_id: int = None,
    ):
        """Store or update a cache entry."""
        from app.db.sql.repositories.execution_cache import ExecutionCacheRepository

        ExecutionCacheRepository.sync_store(project_id, node_id, node_hash, result, workflow_id)

    @staticmethod
    def cache_evict_lru(project_id: int, node_id: int, keep: int = 10):
        """Keep only the most recent ``keep`` cache entries per (project_id, node_id)."""
        from app.db.sql.repositories.execution_cache import ExecutionCacheRepository

        ExecutionCacheRepository.sync_evict_lru(project_id, node_id, keep)

    @staticmethod
    def cache_invalidate_workflow(workflow_id: int) -> int:
        """Delete all cache entries for a workflow. Returns count deleted."""
        from app.db.sql.repositories.execution_cache import ExecutionCacheRepository

        return ExecutionCacheRepository.sync_invalidate_workflow(workflow_id)
