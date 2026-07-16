"""Workflow snapshot model — stores versioned checkpoints for undo/redo."""

from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship

from .base import SQLAlchemyBase, TimestampMixin


class WorkflowSnapshot(SQLAlchemyBase, TimestampMixin):
    __tablename__ = "workflow_snapshots"

    id = Column(Integer, primary_key=True, autoincrement=True)
    workflow_id = Column(
        Integer,
        ForeignKey("workflows.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    version = Column(Integer, nullable=False)
    snapshot = Column(JSONB, nullable=False)
    label = Column(String(255), nullable=True)

    workflow = relationship("Workflow", back_populates="snapshots")
