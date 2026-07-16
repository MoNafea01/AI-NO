"""Execution cache model — stores hash-keyed results for node re-execution avoidance."""

from sqlalchemy import BigInteger, Column, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship

from .base import SQLAlchemyBase, TimestampMixin


class ExecutionCache(SQLAlchemyBase, TimestampMixin):
    __tablename__ = "execution_cache"
    __table_args__ = (
        UniqueConstraint("project_id", "hash", name="uq_project_hash"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    workflow_id = Column(
        Integer, ForeignKey("workflows.id", ondelete="CASCADE"),
        nullable=True, index=True,
    )
    node_id = Column(BigInteger, ForeignKey("nodes.id", ondelete="CASCADE"), nullable=False)
    hash = Column(String(64), nullable=False, index=True)
    result = Column(JSONB, nullable=True)

    project = relationship("Project", back_populates="caches")
