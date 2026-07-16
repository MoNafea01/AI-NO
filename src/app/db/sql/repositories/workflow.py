"""Workflow repository — CRUD for workflows, workflow runs, and workflow steps."""


import uuid

from typing import Optional
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.db.sql.models.node import Node
from app.db.sql.models.workflow import Workflow, WorkflowRun, WorkflowStep

from .base import BaseRepository


class WorkflowRepository(BaseRepository[Workflow]):
    model = Workflow

    async def get_by_project(self, project_id: int) -> list[Workflow]:
        statement = select(Workflow).order_by(Workflow.id)
        if project_id is not None:
            statement = statement.where(Workflow.project_id == project_id)
        async with self.session_factory() as session:
            result = await session.execute(statement)
            return list(result.scalars().all())

    async def clone_workflow(self, workflow_id: int, new_name: str = None) -> Optional[Workflow]:
        """Deep-copy a workflow and all its nodes, generating new node IDs."""
        async with self.session_factory() as session:
            original = await session.get(Workflow, workflow_id)
            if not original:
                return None

            new_wf = Workflow(
                project_id=original.project_id,
                name=new_name or f"{original.name} (copy)",
                description=original.description,
            )
            session.add(new_wf)
            await session.flush()

            nodes_result = await session.execute(
                select(Node).where(Node.workflow_id == workflow_id)
            )

            old_to_new: dict[int, int] = {}
            new_nodes: list[Node] = []

            for node in nodes_result.scalars().all():
                new_id = uuid.uuid4().int & ((1 << 63) - 1)
                old_to_new[node.id] = new_id
                new_nodes.append((node, new_id))

            def _remap_ports(ports: dict | None, mapping: dict[int, int]) -> dict:
                if not ports:
                    return {}
                remapped = {}
                for port_name, ref in ports.items():
                    if not isinstance(ref, str):
                        remapped[port_name] = ref
                        continue
                    parts = ref.split(":")
                    if parts:
                        try:
                            ref_node_id = int(parts[0])
                            if ref_node_id in mapping:
                                parts[0] = str(mapping[ref_node_id])
                        except (ValueError, TypeError):
                            pass
                    remapped[port_name] = ":".join(parts)
                return remapped

            for node, new_id in new_nodes:
                new_node = Node(
                    id=new_id,
                    node_name=node.node_name,
                    payload=node.payload,
                    params=node.params,
                    task=node.task,
                    type=node.type,
                    project_id=node.project_id,
                    component_id=node.component_id,
                    workflow_id=new_wf.id,
                    out_ports=_remap_ports(node.out_ports, old_to_new),
                    in_ports=_remap_ports(node.in_ports, old_to_new),
                    gui_meta=node.gui_meta,
                )
                session.add(new_node)

            await session.commit()
            await session.refresh(new_wf)
            return new_wf


class WorkflowRunRepository(BaseRepository[WorkflowRun]):
    model = WorkflowRun

    async def get_by_workflow(self, workflow_id: int, limit: int = 50) -> list[WorkflowRun]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(WorkflowRun)
                .where(WorkflowRun.workflow_id == workflow_id)
                .order_by(WorkflowRun.id.desc())
                .limit(limit)
            )
            return list(result.scalars().all())

    async def get_with_steps(self, run_id: int) -> Optional[WorkflowRun]:
        async with self.session_factory() as session:
            result = await session.execute(
                select(WorkflowRun)
                .where(WorkflowRun.id == run_id)
                .options(selectinload(WorkflowRun.steps))
            )
            return result.scalar_one_or_none()

    async def create_run(self, workflow_id: int, changed_node_ids: list[int]) -> WorkflowRun:
        async with self.session_factory() as session:
            run = WorkflowRun(
                workflow_id=workflow_id,
                status="pending",
                changed_node_ids=changed_node_ids,
            )
            session.add(run)
            await session.commit()
            await session.refresh(run)
            return run


    async def update_run_status(
        self, run_id: int, status: str, error: str = None, result: dict = None
    ):
        kwargs = {"status": status}
        if error is not None:
            kwargs["error"] = error
        if result is not None:
            kwargs["result"] = result
        await self.update(run_id, **kwargs)

    async def _create_instance(self, model_class, **kwargs):
        async with self.session_factory() as session:
            instance = model_class(**kwargs)
            session.add(instance)
            await session.commit()
            await session.refresh(instance)
            return instance

class WorkflowStepRepository(BaseRepository[WorkflowStep]):
    model = WorkflowStep

    async def create_step(self, run_id: int, node_id: int, node_type: str) -> WorkflowStep:
        return await self.create(
            run_id=run_id,
            node_id=node_id,
            node_type=node_type,
            status="pending",
        )

    async def update_step_status(self, step_id: int, status: str, error: Optional[str] = None, result: Optional[dict] = None):
        kwargs = {"status": status}
        if error is not None:
            kwargs["error"] = error
        if result is not None:
            kwargs["result"] = result
        await self.update(step_id, **kwargs)

