"""Workflow snapshot repository — CRUD for undo/redo checkpoints."""

import logging

from sqlalchemy import delete, select

from app.db.sql.models.workflow import Workflow
from app.db.sql.models.workflow_snapshot import WorkflowSnapshot

from .base import BaseRepository

logger = logging.getLogger(__name__)


class WorkflowSnapshotRepository(BaseRepository[WorkflowSnapshot]):
    model = WorkflowSnapshot

    async def get_by_workflow(self, workflow_id: int) -> list[WorkflowSnapshot]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(WorkflowSnapshot)
                .filter_by(workflow_id=workflow_id)
                .order_by(WorkflowSnapshot.version)
            )
            return list(result.scalars().all())

    async def get_latest(self, workflow_id: int) -> WorkflowSnapshot | None:
        async with self.session_factory() as session:
            result = await session.execute(
                select(WorkflowSnapshot)
                .filter_by(workflow_id=workflow_id)
                .order_by(WorkflowSnapshot.version.desc())
                .limit(1)
            )
            return result.scalar_one_or_none()

    async def get_by_version(
        self, workflow_id: int, version: int
    ) -> WorkflowSnapshot | None:
        async with self.session_factory() as session:
            result = await session.execute(
                select(WorkflowSnapshot).filter_by(
                    workflow_id=workflow_id, version=version
                )
            )
            return result.scalar_one_or_none()

    async def get_by_id(self, snapshot_id: int) -> WorkflowSnapshot | None:
        async with self.session_factory() as session:
            return await session.get(WorkflowSnapshot, snapshot_id)

    async def create_snapshot(
        self,
        workflow_id: int,
        snapshot: list[dict],
        label: str = None,
        current_version: int | None = None,
    ) -> WorkflowSnapshot:
        """Create a new snapshot with auto-incremented version.

        If *current_version* is set and less than the latest version,
        all snapshots with version > current_version are deleted first
        (standard undo/redo truncation).

        Enforces max 10 versions per workflow (deletes oldest).
        """
        async with self.session_factory() as session:
            result = await session.execute(
                select(WorkflowSnapshot)
                .filter_by(workflow_id=workflow_id)
                .order_by(WorkflowSnapshot.version.desc())
                .limit(1)
            )
            latest = result.scalar_one_or_none()

            # Truncate forward history if creating from a non-latest position
            if current_version is not None and latest and current_version < latest.version:
                await session.execute(
                    delete(WorkflowSnapshot).where(
                        WorkflowSnapshot.workflow_id == workflow_id,
                        WorkflowSnapshot.version > current_version,
                    )
                )
                # Re-fetch latest after truncation
                result = await session.execute(
                    select(WorkflowSnapshot)
                    .filter_by(workflow_id=workflow_id)
                    .order_by(WorkflowSnapshot.version.desc())
                    .limit(1)
                )
                latest = result.scalar_one_or_none()

            next_version = (latest.version + 1) if latest else 1

            entry = WorkflowSnapshot(
                workflow_id=workflow_id,
                version=next_version,
                snapshot=snapshot,
                label=label,
            )
            session.add(entry)
            await session.flush()

            # LRU eviction: keep only the latest 10
            all_versions = await session.execute(
                select(WorkflowSnapshot.id)
                .filter_by(workflow_id=workflow_id)
                .order_by(WorkflowSnapshot.version.desc())
            )
            ids = [r[0] for r in all_versions.all()]
            if len(ids) > 10:
                ids_to_delete = ids[10:]
                await session.execute(
                    delete(WorkflowSnapshot).where(
                        WorkflowSnapshot.id.in_(ids_to_delete)
                    )
                )

            # Update workflow.current_version
            wf = await session.get(Workflow, workflow_id)
            if wf:
                wf.current_version = next_version

            await session.commit()
            await session.refresh(entry)
            return entry
