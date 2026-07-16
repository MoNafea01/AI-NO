"""Node repository."""

import logging
import os
import uuid

from sqlalchemy import delete, select

from app.db.sql.models.node import Node

from .base import BaseRepository

logger = logging.getLogger(__name__)


class NodeRepository(BaseRepository[Node]):
    model = Node

    # ── Read ──────────────────────────────────────────────────────────────

    async def get_by_project(self, project_id: int, skip: int = 0, limit: int = 1000) -> list[Node]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(Node).where(Node.project_id == project_id).offset(skip).limit(limit)
            )
            return list(result.scalars().all())

    async def get_by_workflow(
        self, workflow_id: int, project_id: int | None = None, skip: int = 0, limit: int = 1000
    ) -> list[Node]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(Node)
                .where(Node.workflow_id == workflow_id, Node.project_id == project_id)
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())

    async def get_by_pk(self, project_id: int, node_id: int) -> Node | None:
        async with self.session_factory() as session:
            result = await session.execute(
                select(Node).where(Node.project_id == project_id, Node.id == node_id)
            )
            return result.scalar_one_or_none()

    async def get_by_node_id(self, node_id: int, project_id: int | None = None) -> Node | None:
        async with self.session_factory() as session:
            query = select(Node).where(Node.id == node_id)
            if project_id is not None:
                query = query.where(Node.project_id == project_id)
            result = await session.execute(query)
            return result.scalar_one_or_none()

    async def get_by_component(
        self, component_id: int, project_id: int | None = None
    ) -> list[Node]:
        async with self.session_factory() as session:
            query = select(Node).where(Node.component_id == component_id)
            if project_id is not None:
                query = query.where(Node.project_id == project_id)
            result = await session.execute(query)
            return list(result.scalars().all())

    async def get_by_node_name(self, node_name: str, project_id: int | None = None) -> Node | None:
        async with self.session_factory() as session:
            query = select(Node).where(Node.node_name == node_name)
            if project_id is not None:
                query = query.where(Node.project_id == project_id)
            result = await session.execute(query)
            return result.scalar_one_or_none()

    # ── Bulk / Clear ──────────────────────────────────────────────────────

    async def clear_project_nodes(self, project_id: int) -> int:
        async with self.session_factory() as session:
            result = await session.execute(delete(Node).where(Node.project_id == project_id))
            await session.commit()
            return result.rowcount

    async def clear_workflow_nodes(self, workflow_id: int, project_id: int | None = None) -> int:
        async with self.session_factory() as session:
            result = await session.execute(
                delete(Node).where(Node.workflow_id == workflow_id, Node.project_id == project_id)
            )
            await session.commit()
            return result.rowcount

    async def clear_all(self) -> int:
        """Delete every node row across all projects."""
        async with self.session_factory() as session:
            result = await session.execute(delete(Node))
            await session.commit()
            return result.rowcount

    # ── Create ────────────────────────────────────────────────────────────

    async def create(self, **kwargs) -> Node:
        if "id" not in kwargs:
            kwargs["id"] = uuid.uuid4().int & ((1 << 63) - 1)

        return await super().create(**kwargs)

    async def upsert_from_payload(self, data: dict) -> Node:
        """Create or update a node from a full payload dict.

        Normalizes legacy field names (``node_id`` → ``id``, ``node_data``
        → ``payload``) before persisting.  Returns the created/updated Node.
        """
        node_id = data.get("id") or data.get("node_id")
        if not node_id:
            node_id = uuid.uuid4().int & ((1 << 63) - 1)

        node_name = data.get("node_name", "")
        project_id = data.get("project_id")
        node_type = data.get("type") or data.get("node_type", "general")
        task = data.get("task", "general")
        params = data.get("params", {})
        workflow_id = data.get("workflow_id")
        component_id = data.get("component_id")
        in_ports = data.get("in_ports") or {}
        out_ports = data.get("out_ports") or {}
        gui_meta = data.get("gui_meta") or {}

        if "location_x" in data:
            gui_meta["location_x"] = data["location_x"]
        if "location_y" in data:
            gui_meta["location_y"] = data["location_y"]
        if "displayed_name" in data:
            gui_meta["displayed_name"] = data["displayed_name"]

        # Store node_data path in payload JSONB column
        payload = data.get("payload") or data.get("node_data")
        if isinstance(payload, str):
            payload = {"node_data": payload}
        elif payload is None:
            payload = {}

        existing = await self.get_by_node_id(node_id, project_id)
        if existing:
            kwargs = dict(
                node_name=node_name,
                type=node_type,
                task=task,
                params=params,
                component_id=component_id,
                workflow_id=workflow_id,
                in_ports=in_ports,
                out_ports=out_ports,
                gui_meta=gui_meta,
                payload=payload,
            )
            return await self.update(node_id, **kwargs)
        else:
            return await self.create(
                id=node_id,
                node_name=node_name,
                type=node_type,
                task=task,
                params=params,
                project_id=project_id,
                component_id=component_id,
                workflow_id=workflow_id,
                in_ports=in_ports,
                out_ports=out_ports,
                gui_meta=gui_meta,
                payload=payload,
                status="pending",
            )

    # ── Delete ────────────────────────────────────────────────────────────

    async def delete_with_files(self, node_id: int, project_id: int | None = None) -> bool:
        """Delete a node and remove its .pkl file."""
        node = await self.get_by_node_id(node_id, project_id)
        if not node:
            return False

        # Remove .pkl file
        pld = node.payload or {}
        node_path = pld.get("node_data")
        if node_path and os.path.exists(str(node_path)):
            try:
                os.remove(node_path)
            except OSError as e:
                logger.warning("Failed to remove .pkl %s: %s", node_path, e)

        return await self.delete(node_id)

    async def clear_workflow_with_files(
        self, workflow_id: int, project_id: int | None = None
    ) -> int:
        """Delete all nodes for a workflow and remove their .pkl files."""
        nodes = await self.get_by_workflow(workflow_id, project_id)
        for node in nodes:
            pld = node.payload or {}
            node_path = pld.get("node_data")
            if node_path and os.path.exists(str(node_path)):
                try:
                    os.remove(node_path)
                except OSError:
                    pass
        return await self.clear_workflow_nodes(workflow_id, project_id)

    async def clear_project_with_files(self, project_id: int) -> int:
        """Delete all nodes + .pkl files for a project."""
        nodes = await self.get_by_project(project_id)
        for node in nodes:
            pld = node.payload or {}
            node_path = pld.get("node_data")
            if node_path and os.path.exists(str(node_path)):
                try:
                    os.remove(node_path)
                except OSError:
                    pass

        return await self.clear_project_nodes(project_id)

    async def clear_all_with_files(self) -> int:
        """Delete every node + .pkl files across all projects."""
        from app.engine.configs.const_ import SAVING_DIR

        count = await self.clear_all()

        # Clean up the saving directory
        import shutil

        saving_dir = os.path.abspath(SAVING_DIR)
        if os.path.exists(saving_dir):
            shutil.rmtree(saving_dir, ignore_errors=True)

        return count

    # ── Sync (Celery engine layer) ────────────────────────────────────

    @staticmethod
    def sync_get_by_workflow(project_id: int, workflow_id: int) -> list[Node]:
        """Fetch all nodes for a workflow synchronously."""
        from app.engine.repositories.db import get_sync_session

        with get_sync_session() as session:
            return list(
                session.query(Node)
                .filter(
                    Node.project_id == project_id,
                    Node.workflow_id == workflow_id,
                )
                .all()
            )

    @staticmethod
    def sync_set_status(node_id: int, status: str):
        """Set a single node's status synchronously."""
        from app.engine.repositories.db import get_sync_session

        with get_sync_session() as session:
            node = session.query(Node).filter_by(id=node_id).first()
            if node:
                node.status = status
                session.commit()

    @staticmethod
    def sync_reset_status_batch(node_ids: set[int], node_map: dict):
        """Reset a batch of nodes to 'pending' using a pre-fetched node_map."""
        from app.engine.repositories.db import get_sync_session

        with get_sync_session() as session:
            for nid in node_ids:
                node = node_map.get(nid)
                if node:
                    session.merge(node)
                    node.status = "pending"
            session.commit()
