"""Project repository."""

from typing import List, Optional
from sqlalchemy import delete, select, func

from .base import BaseRepository
from app.db.sql.models.project import Project


class ProjectRepository(BaseRepository[Project]):
    model = Project

    async def get_filtered(
        self,
        user_id: int,
        model_name: Optional[str] = None,
        dataset_name: Optional[str] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Project]:
        async with self.session_factory() as session:
            query = select(Project).where(Project.user_id == user_id)
            if model_name:
                query = query.where(
                    Project.model == model_name
                )
            if dataset_name:
                query = query.where(
                    Project.dataset == dataset_name
                )
            result = await session.execute(query.offset(skip).limit(limit))
            return list(result.scalars().all())

    async def delete_empty_projects(self, user_id: int) -> int:
        async with self.session_factory() as session:
            from app.db.sql.models.node import Node

            subq = select(Node.project_id).where(Node.project_id.is_not(None))
            statement = (
                delete(Project)
                .where(
                    Project.user_id == user_id,
                    Project.id.notin_(subq)
                )
            )
            result = await session.execute(statement)
            await session.commit()

            return result.rowcount

    async def get_distinct_models(self, user_id: int) -> List[str]:
        async with self.session_factory() as session:
            query = (
                select(Project.model)
                .where(
                    Project.user_id == user_id,
                    Project.model.is_not(None),
                    Project.model != ''
                )
                .distinct()
                .order_by(Project.model)
            )
            result = await session.execute(query)
            return list(result.scalars().all())

    async def get_distinct_datasets(self, user_id: int) -> List[str]:
        async with self.session_factory() as session:
            query = (
                select(Project.dataset)
                .where(
                    Project.user_id == user_id,
                    Project.dataset.is_not(None),
                    Project.dataset != ''
                )
                .distinct()
                .order_by(Project.dataset)
            )
            result = await session.execute(query)
            return list(result.scalars().all())
