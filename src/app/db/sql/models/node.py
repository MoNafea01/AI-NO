"""Node SQLAlchemy model."""

from sqlalchemy import (
    JSON,
    BigInteger,
    Column,
    ForeignKey,
    Integer,
    String,
)
from sqlalchemy.orm import relationship

from .base import SQLAlchemyBase, TimestampMixin


class Node(SQLAlchemyBase, TimestampMixin):
    """A single node in an ML workflow graph."""

    __tablename__ = "nodes"

    id = Column(BigInteger, primary_key=True, nullable=False)
    node_name = Column(String(255), nullable=False)
    payload = Column(JSON, default=dict)
    params = Column(JSON, default=dict)
    task = Column(String(255), default="general")
    type = Column(String(255), default="general")

    # Foreign key
    project_id = Column(
        Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=True
    )
    component_id = Column(
        BigInteger,
        ForeignKey("components.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    workflow_id = Column(
        Integer,
        ForeignKey("workflows.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    # Graph connections (stored as JSON dicts: {"port_name": "node_id:group_idx:port_idx"})
    out_ports = Column(JSON, default=dict)
    in_ports = Column(JSON, default=dict)

    # Execution status  (pending / running / completed / failed)
    status = Column(String(20), default="pending", nullable=False)

    # Visual editor metadata
    gui_meta = Column(JSON, default=dict)

    # Relationships
    project = relationship("Project", back_populates="nodes")
    component = relationship("Component", back_populates="nodes")
    workflow = relationship("Workflow", back_populates="nodes")

    def __repr__(self) -> str:
        return f"<Node(project_id={self.project_id}, id={self.id}, name='{self.node_name}')>"
