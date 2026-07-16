"""Celery workflow tasks — executes ML workflow pipelines in the background.

Dispatched by the ``POST /workflows/{project_id}/{workflow_id}/run`` endpoint.
Runs the full DAG defined by the workflow's nodes in topological order with
**parallel execution** within each rank level via ``ThreadPoolExecutor``.

Uses **hash-based execution caching** — if a node's inputs haven't changed
since the last run, the cached result is returned without re-execution.

Node and run status is written to the DB via repository sync methods.
"""

import logging
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed

from app.celery_app import celery_app
from app.db.sql.repositories.node import NodeRepository
from app.db.sql.repositories.workflow import WorkflowRunRepository, WorkflowStepRepository
from app.engine.dag import (
    build_dag,
    compute_node_hash,
    find_downstream,
    topological_levels,
)
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
        WorkflowRunRepository.sync_update_status(run_id, "running")

        nodes = NodeRepository.sync_get_by_workflow(project_id, workflow_id)

        dag = build_dag(nodes)
        node_map = {n.id: n for n in nodes}

        if changed_node_ids:
            subset = find_downstream(dag, changed_node_ids)
            NodeRepository.sync_reset_status_batch(subset, node_map)
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
                            node_name=node.node_name,
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
        WorkflowRunRepository.sync_update_status(run_id, final_status)

        logger.info(
            "Workflow run %s — %s (%d errors)", run_id, final_status, error_count
        )
        return {"status": final_status, "run_id": run_id}

    except Exception as exc:
        logger.exception("Workflow run %s failed entirely", run_id)
        WorkflowRunRepository.sync_update_status(run_id, "failed", error=str(exc))
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
        NodeRepository.sync_set_status(node_id, "completed")
        WorkflowStepRepository.sync_create(run_id, node_id, node_type)
        WorkflowStepRepository.sync_update(run_id, node_id, "completed", result=cached)
        return True, node_hash

    # ── Fresh execution ─────────────────────────────────────────────
    NodeRepository.sync_set_status(node_id, "running")
    WorkflowStepRepository.sync_create(run_id, node_id, node_type)

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
    WorkflowStepRepository.sync_update(
        run_id, node_id, step_status,
        error=(result or {}).get("message") if not success else None,
        result=result,
    )
    NodeRepository.sync_set_status(node_id, step_status)

    return success, node_hash
