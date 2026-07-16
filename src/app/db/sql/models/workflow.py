"""Workflow models — Workflow (tab), WorkflowRun (execution), WorkflowStep (node step)."""

from sqlalchemy import (
    JSON,
    BigInteger,
    Column,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship

from .base import SQLAlchemyBase, TimestampMixin


class Workflow(SQLAlchemyBase, TimestampMixin):
    """A workflow tab within a project — groups a subset of nodes."""

    __tablename__ = "workflows"

    id = Column(Integer, primary_key=True, autoincrement=True)
    project_id = Column(
        Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True
    )
    name = Column(String(255), nullable=False, default="Untitled")
    description = Column(Text, nullable=True, default="")
    current_version = Column(Integer, nullable=True, default=None)

    project = relationship("Project", back_populates="workflows")
    nodes = relationship("Node", back_populates="workflow", cascade="all, delete-orphan")
    runs = relationship("WorkflowRun", back_populates="workflow", cascade="all, delete-orphan")
    snapshots = relationship("WorkflowSnapshot", back_populates="workflow", cascade="all, delete-orphan")


class WorkflowRun(SQLAlchemyBase, TimestampMixin):
    """A single execution run of a workflow."""

    __tablename__ = "workflow_runs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    workflow_id = Column(
        Integer, ForeignKey("workflows.id", ondelete="CASCADE"), nullable=False, index=True
    )
    status = Column(String(32), nullable=False, default="pending")
    # pending | running | completed | failed
    changed_node_ids = Column(JSON, default=list)
    result = Column(JSONB, nullable=True)
    error = Column(Text, nullable=True)

    workflow = relationship("Workflow", back_populates="runs")
    steps = relationship("WorkflowStep", back_populates="run", cascade="all, delete-orphan")


class WorkflowStep(SQLAlchemyBase, TimestampMixin):
    """A single node execution step within a workflow run."""

    __tablename__ = "workflow_steps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    run_id = Column(
        Integer, ForeignKey("workflow_runs.id", ondelete="CASCADE"), nullable=False, index=True
    )
    node_id = Column(BigInteger, nullable=False)
    node_type = Column(String(255), nullable=True)
    status = Column(String(32), nullable=False, default="pending")
    # pending | running | completed | failed
    result = Column(JSONB, nullable=True)
    error = Column(Text, nullable=True)

    run = relationship("WorkflowRun", back_populates="steps")
