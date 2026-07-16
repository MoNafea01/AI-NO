"""Workflow executor — background execution with DAG-based ordering and status tracking.

Runs nodes in topological levels with parallel execution via ThreadPoolExecutor.
Dispatches to the Celery ``workflow_queue`` so runs appear in Flower.
Uses hash-based execution caching to skip nodes whose inputs haven't changed.
"""

import logging

from app.engine.dag import (  # noqa: F401 — re-exported for shared use
    build_dag,
    find_downstream,
    topological_sort,
)

logger = logging.getLogger(__name__)


class WorkflowExecutor:
    """Launches background workflow execution via Celery with status tracking."""

    async def run_workflow(
        self,
        workflow_id: int,
        project_id: int,
        changed_node_ids: list[int],
        db_client,
    ) -> int:
        """Create a WorkflowRun record and dispatch to Celery.

        Returns the run_id immediately.  Poll ``GET /v1/workflows/runs/{run_id}``
        for status.
        """
        from app.db.sql.repositories.workflow import WorkflowRunRepository
        from app.tasks.workflow import execute_workflow

        run_repo = WorkflowRunRepository(db_client)
        run = await run_repo.create(
            workflow_id=workflow_id,
            status="pending",
            changed_node_ids=changed_node_ids,
        )

        execute_workflow.delay(
            run_id=run.id,
            project_id=project_id,
            workflow_id=workflow_id,
            changed_node_ids=changed_node_ids,
        )

        return run.id
