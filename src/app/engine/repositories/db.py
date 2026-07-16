"""Database access helpers for engine repositories.

Provides a thin synchronous wrapper around the async SQLAlchemy session so
that the *existing* synchronous engine code (BaseNode, NodeSaver …) keeps
working without being rewritten to async.

Usage (inside any repository class):
    from .db import get_sync_session, NodeModel
    with get_sync_session() as session:
        node = session.query(NodeModel).filter_by(id=nid).first()
"""

from __future__ import annotations

from collections.abc import Generator
from contextlib import contextmanager

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings
from app.db.sql.models.component import Component as ComponentModel
from app.db.sql.models.node import Node as NodeModel

# ── Sync engine (engine code is synchronous) ──
_PG_URL = (
    f"postgresql+psycopg2://{settings.POSTGRES_USERNAME}:{settings.POSTGRES_PASSWORD}"
    f"@{settings.POSTGRES_HOST}:{settings.POSTGRES_PORT}/{settings.POSTGRES_MAIN_DB}"
)

_sync_engine = create_engine(_PG_URL, pool_pre_ping=True)
_SyncSessionLocal = sessionmaker(bind=_sync_engine, autoflush=False, expire_on_commit=False)


@contextmanager
def get_sync_session() -> Generator[Session, None, None]:
    """Yield a synchronous SQLAlchemy session, auto-closing afterwards."""
    session = _SyncSessionLocal()
    try:
        yield session
    finally:
        session.close()


__all__ = ["get_sync_session", "NodeModel", "ComponentModel"]
