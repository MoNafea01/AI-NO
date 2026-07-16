"""Base repository with common async CRUD operations."""

from typing import Generic, TypeVar

from sqlalchemy import delete, inspect, select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.db.sql.models.base import SQLAlchemyBase

T = TypeVar("T", bound=SQLAlchemyBase)


class BaseRepository(Generic[T]):
    """Generic async repository for SQLAlchemy models."""

    model: type[T]

    def __init__(self, session_factory: async_sessionmaker[AsyncSession]):
        self.session_factory = session_factory

    def _has_user_id(self) -> bool:
        """Helper to safely check if model has user_id attribute using SQLAlchemy inspection."""
        mapper = inspect(self.model)
        return "user_id" in mapper.attrs

    async def get_by_id(self, id: int, user_id: int | None = None) -> T | None:
        async with self.session_factory() as session:
            query = select(self.model).where(self.model.id == id)
            if user_id is not None and self._has_user_id():
                query = query.where(getattr(self.model, "user_id") == user_id)
            result = await session.execute(query)
            return result.scalars().first()

    async def get_all(self, user_id: int | None = None, skip: int = 0, limit: int = 100) -> list[T]:
        async with self.session_factory() as session:
            query = select(self.model).offset(skip).limit(limit)
            if user_id is not None and self._has_user_id():
                query = query.where(getattr(self.model, "user_id") == user_id)
            result = await session.execute(query)
            return list(result.scalars().all())

    async def create(self, **kwargs) -> T:
        async with self.session_factory() as session:
            instance = self.model(**kwargs)
            session.add(instance)
            await session.commit()
            await session.refresh(instance)
            return instance

    async def update(self, id: int, **kwargs) -> T | None:
        async with self.session_factory() as session:
            instance = await session.get(self.model, id)
            if not instance:
                return None
            for key, value in kwargs.items():
                setattr(instance, key, value)
            await session.commit()
            await session.refresh(instance)
            return instance

    async def delete(self, id: int, user_id: int | None = None) -> bool:
        async with self.session_factory() as session:
            instance = await session.get(self.model, id)
            if not instance:
                return False
            if user_id is not None and self._has_user_id():
                if getattr(instance, "user_id") != user_id:
                    return False
            await session.delete(instance)
            await session.commit()
            return True

    async def delete_many(self, ids: list[int], user_id: int | None = None) -> int:
        async with self.session_factory() as session:
            query = delete(self.model).where(self.model.id.in_(ids))

            if user_id is not None and self._has_user_id():
                query = query.where(getattr(self.model, "user_id") == user_id)

            result = await session.execute(query)
            await session.commit()
            return result.rowcount
