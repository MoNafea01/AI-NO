"""Shared test fixtures for AI-NO test suite."""

import os
from unittest.mock import AsyncMock, MagicMock, patch

import pytest


@pytest.fixture(scope="session", autouse=True)
def override_settings():
    """Force test-specific settings without touching .env."""
    os.environ["SECRET_KEY"] = "test-secret-key-for-pytest"
    os.environ["ENV"] = "testing"
    os.environ["POSTGRES_MAIN_DB"] = "aino_test_db"
    yield


@pytest.fixture
def auth_headers():
    """Generate a valid JWT for test authentication."""
    from app.core.auth import create_access_token

    token = create_access_token({"sub": "test@test.com", "user_id": 1})
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def mock_db_session():
    """Provide a mock async DB session."""
    session = AsyncMock()
    session.execute = AsyncMock()
    session.commit = AsyncMock()
    session.rollback = AsyncMock()
    session.close = AsyncMock()
    return session


@pytest.fixture
def mock_db_client():
    """Provide a mock async_sessionmaker bound to mock sessions."""
    mock_session_factory = MagicMock()
    mock_session_factory.return_value.__aenter__ = AsyncMock()
    mock_session_factory.return_value.__aexit__ = AsyncMock()
    return mock_session_factory


@pytest.fixture
def mock_node_saver():
    """Mock EnginePersistence.save_result to prevent filesystem and DB writes."""
    with patch("app.engine.base_node.EnginePersistence") as mock:
        mock.save_result = MagicMock(return_value={"node_id": 1, "message": "saved"})
        yield mock


@pytest.fixture
def mock_node_loader():
    """Mock EnginePersistence.load_node_meta to prevent DB reads."""
    with patch("app.engine.repositories.execution.EnginePersistence") as mock:
        mock.load_node_meta = MagicMock(return_value=(True, {"node_id": 1, "node_data": MagicMock()}))
        yield mock


@pytest.fixture
def mock_data_extractor():
    """Mock EnginePersistence.load_data to prevent filesystem reads."""
    with patch("app.engine.repositories.execution.EnginePersistence") as mock:
        mock.load_data = MagicMock(return_value=MagicMock())
        yield mock
