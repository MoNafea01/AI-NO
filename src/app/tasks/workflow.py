"""Celery workflow tasks — executes ML workflow pipelines in the background.

Dispatched by the ``POST /workflows/{project_id}/{workflow_id}/run`` endpoint.
Runs the full DAG defined by the workflow's nodes in topological order with
**parallel execution** within each rank level via ``ThreadPoolExecutor``.

Uses **hash-based execution caching** — if a node's inputs haven't changed
since the last run, the cached result is returned without re-execution.

Node and run status is written to the DB via per-thread sync sessions.
"""

import logging
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed

from app.celery_app import celery_app
from app.db.sql.models.node import Node
from app.db.sql.models.workflow import WorkflowRun, WorkflowStep
from app.engine.dag import (
    build_dag,
    compute_node_hash,
    find_downstream,
    topological_levels,
)
from app.engine.repositories.db import get_sync_session
from app.engine.repositories.execution import EnginePersistence


logger = logging.getLogger(__name__)


@celery_app.task(
    bind=True,
    name="app.tasks.workflow.execute_workflow",
    max_retries=3,
    default_retry_delay=5,
)
def execute_workflow(
    self,
    run_id: int,
    project_id: int,
    workflow_id: int,
    changed_node_ids: list[int],
) -> dict:
    """Execute nodes in parallel topological levels via Celery.

    * Empty *changed_node_ids* → runs all nodes with ``status == "pending"``.
    * Specific IDs → resets those nodes + downstream dependents to ``"pending"``
      then executes them.

    Within each topological level, independent nodes run concurrently via
    ``ThreadPoolExecutor``.  Each thread creates its own sync DB session.

    Node status is set to ``running`` / ``completed`` / ``failed`` in real time.
    Hash-based caching skips nodes whose inputs haven't changed.
    """
    import tensorflow as tf
    tf.get_logger().setLevel("ERROR")

    from app.services.node_service import NODE_CLASS_REGISTRY

    try:
        # ── Sequential setup ──────────────────────────────────────────
        with get_sync_session() as session:
            _update_run_status(session, run_id, "running")

            nodes = session.query(Node).filter(
                Node.project_id == project_id,
                Node.workflow_id == workflow_id,
            ).all()

            dag = build_dag(nodes)
            node_map = {n.id: n for n in nodes}

            if changed_node_ids:
                subset = find_downstream(dag, changed_node_ids)
                _reset_nodes_status(session, subset, node_map)
            else:
                subset = {n.id for n in nodes if n.status == "pending"}

        # ── Parallel execution by level ───────────────────────────────
        levels = topological_levels(dag, subset)
        error_count = 0
        error_lock = threading.Lock()
        parent_hashes: dict[int, str] = {}

        for level in levels:
            if not level:
                continue

            with ThreadPoolExecutor(max_workers=len(level)) as executor:
                futures = {}
                for node_id in level:
                    node = node_map.get(node_id)
                    if not node:
                        continue
                    if node.type not in NODE_CLASS_REGISTRY:
                        logger.warning(
                            "Skipping node %s — unknown type '%s'",
                            node_id, node.type,
                        )
                        continue

                    future = executor.submit(
                        _execute_node,
                        node_id=node_id,
                        node_type=node.type,
                        node_name=node.node_name,
                        params=dict(node.params or {}),
                        project_id=project_id,
                        workflow_id=workflow_id,
                        in_ports=node.in_ports or {},
                        out_ports=node.out_ports or {},
                        run_id=run_id,
                        node_hash=compute_node_hash(
                            node_type=node.type,
                            task=node.task or "general",
                            params=node.params or {},
                            out_ports=node.out_ports or {},
                            in_ports=node.in_ports or {},
                            parent_hashes=parent_hashes,
                        ),
                    )
                    futures[future] = node_id

                for future in as_completed(futures):
                    node_id = futures[future]
                    try:
                        success, node_hash = future.result()
                        parent_hashes[node_id] = node_hash
                        if not success:
                            with error_lock:
                                error_count += 1
                    except Exception:
                        logger.exception(
                            "Thread failed for node %s", node_id
                        )
                        with error_lock:
                            error_count += 1
                        parent_hashes[node_id] = f"error:{node_id}"

        # ── Sequential finalization ───────────────────────────────────
        final_status = "completed" if error_count == 0 else "completed_with_errors"
        with get_sync_session() as session:
            _update_run_status(session, run_id, final_status)

        logger.info(
            "Workflow run %s — %s (%d errors)", run_id, final_status, error_count
        )
        return {"status": final_status, "run_id": run_id}

    except Exception as exc:
        logger.exception("Workflow run %s failed entirely", run_id)
        try:
            with get_sync_session() as session:
                _update_run_status(session, run_id, "failed", error=str(exc))
        except Exception:
            logger.exception("Failed to update run status for %s", run_id)
        try:
            self.retry(exc=exc)
        except Exception as retry_exc:
            return {"status": "failed", "error": str(retry_exc), "run_id": run_id}


# ── Per-node execution (runs inside a thread) ─────────────────────────────


def _execute_node(
    *,
    node_id: int,
    node_type: str,
    node_name: str,
    params: dict,
    project_id: int,
    workflow_id: int,
    in_ports: dict,
    out_ports: dict,
    run_id: int,
    node_hash: str,
) -> tuple[bool, str]:
    """Execute a single node in its own thread + session.

    Returns (success, hash) where *hash* is the content-addressable hash
    used for cache lookups (or the cached hash on hit).
    """
    from app.services.node_service import NodeService

    # ── Cache lookup ────────────────────────────────────────────────
    cached = EnginePersistence.cache_lookup(project_id, node_hash)
    if cached is not None:
        with get_sync_session() as session:
            node = session.query(Node).filter_by(id=node_id).first()
            if node:
                node.status = "completed"
            _create_step(session, run_id, node_id, node_type)
            step = (
                session.query(WorkflowStep)
                .filter_by(run_id=run_id, node_id=node_id)
                .order_by(WorkflowStep.id.desc())
                .first()
            )
            if step:
                step.status = "completed"
                step.result = cached
            session.commit()
        return True, node_hash

    # ── Fresh execution ─────────────────────────────────────────────
    with get_sync_session() as session:
        node = session.query(Node).filter_by(id=node_id).first()
        if node:
            node.status = "running"
            session.commit()

        _create_step(session, run_id, node_id, node_type)

    data = dict(params)
    data.update(
        project_id=project_id,
        workflow_id=workflow_id,
        node_id=node_id,
        node_name=node_name,
        in_ports=in_ports,
        out_ports=out_ports,
    )

    try:
        result = NodeService.execute_node(node_type, data)
        success = bool(result and not result.get("error"))
        step_status = "completed" if success else "failed"
    except Exception as e:
        result = {"message": f"Error: {e}", "error": True}
        success = False
        step_status = "failed"

    # ── Store in cache on success ───────────────────────────────────
    if success:
        EnginePersistence.cache_store(
            project_id=project_id,
            node_id=node_id,
            node_hash=node_hash,
            result=result,
            workflow_id=workflow_id,
        )
        EnginePersistence.cache_evict_lru(project_id, node_id, keep=10)

    # ── Update DB status ────────────────────────────────────────────
    with get_sync_session() as session:
        _update_step(
            session, run_id, node_id, step_status,
            error=(result or {}).get("message") if not success else None,
            result=result,
        )
        node = session.query(Node).filter_by(id=node_id).first()
        if node:
            node.status = step_status
            session.commit()

    return success, node_hash


# ── Status helpers (accept session parameter) ─────────────────────────────


def _update_run_status(session, run_id: int, status: str, error: str = None):
    run = session.query(WorkflowRun).filter(WorkflowRun.id == run_id).first()
    if run:
        run.status = status
        if error is not None:
            run.error = error
        session.commit()


def _create_step(session, run_id: int, node_id: int, node_type: str):
    step = WorkflowStep(
        run_id=run_id, node_id=node_id, node_type=node_type, status="pending"
    )
    session.add(step)
    session.commit()


def _update_step(
    session, run_id: int, node_id: int, status: str,
    error: str = None, result: dict = None,
):
    step = (
        session.query(WorkflowStep)
        .filter_by(run_id=run_id, node_id=node_id)
        .order_by(WorkflowStep.id.desc())
        .first()
    )
    if step:
        step.status = status
        if error is not None:
            step.error = error
        if result is not None:
            step.result = result
        session.commit()


def _set_node_status(session, node: Node, status: str):
    node.status = status
    session.commit()


def _reset_nodes_status(session, node_ids: set[int], node_map: dict[int, Node]):
    for nid in node_ids:
        node = node_map.get(nid)
        if node:
            node.status = "pending"
    session.commit()
