"""Component repository."""

from collections.abc import Iterable
from typing import Any

from sqlalchemy import delete, select
from sqlalchemy.orm import selectinload

from app.db.sql.models.component import Category, Component

from .base import BaseRepository


class ComponentRepository(BaseRepository[Component]):
    model = Component

    def _iter_catalog_categories(
        self, catalog: Any
    ) -> Iterable[tuple[str, list[dict[str, Any]], int]]:
        """Yield normalized (category_name, components, order) tuples from any catalog shape."""
        if isinstance(catalog, dict):
            for order, (category_name, components) in enumerate(catalog.items()):
                yield category_name, list(components or []), order
            return

        if isinstance(catalog, list):
            for order, category_block in enumerate(catalog):
                if not isinstance(category_block, dict):
                    continue

                category_name = category_block.get("name")
                if category_name:
                    yield category_name, list(category_block.get("content") or []), order
                    continue

                # Support dict entries like {"Inputs": [...]} if they appear inside a list.
                for category_name, components in category_block.items():
                    if isinstance(components, list):
                        yield category_name, list(components or []), order
            return

        raise TypeError("Catalog must be a dict or list")

    async def get_all(self, skip: int = 0, limit: int = 100) -> list[Component]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(Component)
                .options(selectinload(Component.category_ref))
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())

    async def get_by_id(self, id: int):
        """Get component by its bigint identifier."""
        async with self.session_factory() as session:
            result = await session.execute(
                select(Component)
                .options(selectinload(Component.category_ref))
                .where(Component.id == id)
            )
            return result.scalar_one_or_none()

    async def get_by_name(self, name: str):
        async with self.session_factory() as session:
            result = await session.execute(select(Component).where(Component.name == name))
            return result.scalar_one_or_none()

    async def get_by_category(self, category: str) -> list[Component]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(Component)
                .options(selectinload(Component.category_ref))
                .join(Category, Component.category_id == Category.id, isouter=True)
                .where(Category.name == category)
            )
            return list(result.scalars().all())

    async def get_by_task(self, task: str) -> list[Component]:
        async with self.session_factory() as session:
            result = await session.execute(select(Component).where(Component.task == task))
            return list(result.scalars().all())

    async def clear_all(self) -> int:
        async with self.session_factory() as session:
            result = await session.execute(delete(Component))
            await session.commit()
            return result.rowcount

    async def sync_components_catalog(self, catalog: Any) -> dict[str, int]:
        """Idempotently sync categories and components from the architecture catalog."""
        created_categories = 0
        updated_categories = 0
        created_components = 0
        updated_components = 0

        async with self.session_factory() as session:
            for category_name, components, order in self._iter_catalog_categories(catalog):
                if not category_name:
                    continue

                category_result = await session.execute(
                    select(Category).where(Category.name == category_name)
                )
                category_row = category_result.scalar_one_or_none()

                if category_row is None:
                    category_row = Category(
                        name=category_name.lower().replace(" ", "_"),
                        display_name=category_name,
                        order=order,
                    )
                    session.add(category_row)
                    await session.flush()
                    created_categories += 1
                else:
                    if category_row.display_name != category_name:
                        category_row.display_name = category_name
                        updated_categories += 1
                    if category_row.order != order:
                        category_row.order = order
                        updated_categories += 1

                for item in components:
                    if not isinstance(item, dict):
                        continue

                    component_id = item.get("component_id")
                    if component_id is None:
                        continue

                    component_result = await session.execute(
                        select(Component).where(Component.id == component_id)
                    )
                    component_row = component_result.scalar_one_or_none()

                    mapped_values = {
                        "name": item.get("name", ""),
                        "displayed_name": item.get("display_name", ""),
                        "description": item.get("description", ""),
                        "order": int(component_id),
                        "category_id": category_row.id,
                        "type": item.get("type", "general"),
                        "task": item.get("task", "general"),
                        "params": item.get("parameters"),
                        "inputs": item.get("inputs"),
                        "outputs": item.get("outputs"),
                        "api_call": item.get("api_call", ""),
                    }

                    if component_row is None:
                        component_row = Component(id=int(component_id), **mapped_values)
                        session.add(component_row)
                        created_components += 1
                    else:
                        for key, value in mapped_values.items():
                            setattr(component_row, key, value)
                        updated_components += 1

            await session.commit()

        return {
            "created_categories": created_categories,
            "updated_categories": updated_categories,
            "created_components": created_components,
            "updated_components": updated_components,
        }
