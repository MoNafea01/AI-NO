"""Execution cache repository — async CRUD for the API layer,
sync helpers for the Celery engine layer."""

import logging

from sqlalchemy import delete, select

from app.db.sql.models.execution_cache import ExecutionCache

from .base import BaseRepository

logger = logging.getLogger(__name__)


class ExecutionCacheRepository(BaseRepository[ExecutionCache]):
    model = ExecutionCache

    # ── Async (API layer) ─────────────────────────────────────────────

    async def lookup(self, project_id: int, node_hash: str) -> ExecutionCache | None:
        async with self.session_factory() as session:
            result = await session.execute(
                select(ExecutionCache).filter_by(project_id=project_id, hash=node_hash)
            )
            return result.scalar_one_or_none()

    async def store(
        self,
        project_id: int,
        node_id: int,
        node_hash: str,
        result: dict,
        workflow_id: int = None,
    ) -> ExecutionCache:
        async with self.session_factory() as session:
            existing = (
                await session.execute(
                    select(ExecutionCache).filter_by(project_id=project_id, hash=node_hash)
                )
            ).scalar_one_or_none()

            if existing:
                existing.result = result
                if workflow_id is not None:
                    existing.workflow_id = workflow_id
                await session.commit()
                await session.refresh(existing)
                return existing

            entry = ExecutionCache(
                project_id=project_id,
                workflow_id=workflow_id,
                node_id=node_id,
                hash=node_hash,
                result=result,
            )
            session.add(entry)
            await session.commit()
            await session.refresh(entry)
            return entry

    async def invalidate_workflow(self, workflow_id: int) -> int:
        async with self.session_factory() as session:
            result = await session.execute(
                delete(ExecutionCache).filter_by(workflow_id=workflow_id)
            )
            await session.commit()
            return result.rowcount

    async def clear_all(self) -> int:
        async with self.session_factory() as session:
            result = await session.execute(delete(ExecutionCache))
            await session.commit()
            return result.rowcount

    # ── Sync (Celery engine layer) ────────────────────────────────────

    @staticmethod
    def sync_lookup(project_id: int, node_hash: str) -> dict | None:
        """Look up cached result by project + hash. Returns result dict or None."""
        from app.engine.repositories.db import get_sync_session

        try:
            with get_sync_session() as session:
                entry = (
                    session.query(ExecutionCache)
                    .filter_by(project_id=project_id, hash=node_hash)
                    .first()
                )
                return entry.result if entry else None
        except Exception:
            return None

    @staticmethod
    def sync_store(
        project_id: int,
        node_id: int,
        node_hash: str,
        result: dict,
        workflow_id: int = None,
    ):
        """Store or update a cache entry."""
        from app.engine.repositories.db import get_sync_session

        try:
            with get_sync_session() as session:
                existing = (
                    session.query(ExecutionCache)
                    .filter_by(project_id=project_id, hash=node_hash)
                    .first()
                )
                if existing:
                    existing.result = result
                    if workflow_id is not None:
                        existing.workflow_id = workflow_id
                else:
                    entry = ExecutionCache(
                        project_id=project_id,
                        workflow_id=workflow_id,
                        node_id=node_id,
                        hash=node_hash,
                        result=result,
                    )
                    session.add(entry)
                session.commit()
        except Exception as e:
            logger.warning("Failed to store cache entry: %s", e)

    @staticmethod
    def sync_evict_lru(project_id: int, node_id: int, keep: int = 10):
        """Keep only the most recent ``keep`` cache entries per (project_id, node_id)."""
        from app.engine.repositories.db import get_sync_session

        try:
            with get_sync_session() as session:
                entries = (
                    session.query(ExecutionCache.id)
                    .filter_by(project_id=project_id, node_id=node_id)
                    .order_by(ExecutionCache.id.desc())
                    .all()
                )
                if len(entries) <= keep:
                    return
                ids_to_delete = [e.id for e in entries[keep:]]
                session.query(ExecutionCache).filter(ExecutionCache.id.in_(ids_to_delete)).delete(
                    synchronize_session=False
                )
                session.commit()
        except Exception as e:
            logger.warning("Failed to evict cache entries: %s", e)

    @staticmethod
    def sync_invalidate_workflow(workflow_id: int) -> int:
        """Delete all cache entries for a workflow. Returns count deleted."""
        from app.engine.repositories.db import get_sync_session

        try:
            with get_sync_session() as session:
                result = session.query(ExecutionCache).filter_by(workflow_id=workflow_id).delete()
                session.commit()
                return result
        except Exception:
            return 0
