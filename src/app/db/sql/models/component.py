"""Component and category SQLAlchemy models."""

from sqlalchemy import Column, BigInteger, Integer, String, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB

from sqlalchemy.orm import relationship

from .base import SQLAlchemyBase


class Category(SQLAlchemyBase):
    """Component category used to group palette templates."""

    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False, unique=True)
    display_name = Column(String(255), default="")
    order = Column(Integer, default=0)

    components = relationship("Component", back_populates="category_ref")

    def __repr__(self) -> str:
        return f"<Category(id={self.id}, name='{self.name}')>"


class Component(SQLAlchemyBase):
    """A reusable component template in the node palette."""

    __tablename__ = "components"

    id = Column(BigInteger, primary_key=True)
    name = Column(String(255), nullable=False)
    displayed_name = Column(String(255), default="")
    description = Column(String(255), default="")
    order = Column(Integer, default=0)
    category_id = Column(
        Integer,
        ForeignKey("categories.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    type = Column(String(255), default="general")
    task = Column(String(255), default="general")
    params = Column(JSONB, nullable=True)
    inputs = Column(JSONB, nullable=True)
    outputs = Column(JSONB, nullable=True)
    api_call = Column(String(100), nullable=False)

    category_ref = relationship("Category", back_populates="components")
    nodes = relationship("Node", back_populates="component")

    def __repr__(self) -> str:
        return f"<Component(id={self.id}, name='{self.name}')>"
