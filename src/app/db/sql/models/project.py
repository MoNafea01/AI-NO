"""Project SQLAlchemy model."""

from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship

from .base import SQLAlchemyBase, TimestampMixin


class Project(SQLAlchemyBase, TimestampMixin):
    """ML workflow project."""

    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True, default="")
    model = Column(String(255), nullable=True)
    dataset = Column(String(255), nullable=True)

    # Relationships
    user = relationship("User", back_populates="projects")
    nodes = relationship("Node", back_populates="project", cascade="all, delete-orphan")
    workflows = relationship("Workflow", back_populates="project", cascade="all, delete-orphan")
    caches = relationship("ExecutionCache", back_populates="project", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<Project(id={self.id}, name='{self.name}')>"
