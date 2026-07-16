"""User SQLAlchemy model."""

from sqlalchemy import Boolean, Column, Integer, String

from .base import SQLAlchemyBase, TimestampMixin

from sqlalchemy.orm import relationship

class User(SQLAlchemyBase, TimestampMixin):
    """Registered user account."""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    
    projects = relationship("Project", back_populates="user", cascade="all, delete-orphan")
    refresh_tokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email='{self.email}')>"
