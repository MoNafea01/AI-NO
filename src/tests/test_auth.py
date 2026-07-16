"""Tests for auth endpoints — register, login, refresh, logout."""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    from app.main import app
    return TestClient(app)


# ── Register ─────────────────────────────────────────────────

class TestRegister:
    @patch("app.api.v1.endpoints.auth._get_user_repo")
    def test_register_success(self, mock_get_repo, client):
        repo = mock_get_repo.return_value
        repo.get_by_email = AsyncMock(return_value=None)
        repo.create = AsyncMock(return_value=MagicMock(id=1, email="new@test.com"))

        resp = client.post("/api/v1/auth/register", json={
            "email": "new@test.com",
            "password": "secret123",
        })
        assert resp.status_code == 201
        data = resp.json()
        assert data["email"] == "new@test.com"
        assert "id" in data

    @patch("app.api.v1.endpoints.auth._get_user_repo")
    def test_register_duplicate_email(self, mock_get_repo, client):
        repo = mock_get_repo.return_value
        repo.get_by_email = AsyncMock(return_value=MagicMock(id=1, email="dup@test.com"))

        resp = client.post("/api/v1/auth/register", json={
            "email": "dup@test.com",
            "password": "secret123",
        })
        assert resp.status_code == 409

    def test_register_invalid_email(self, client):
        resp = client.post("/api/v1/auth/register", json={
            "email": "not-an-email",
            "password": "secret123",
        })
        assert resp.status_code == 422

    @patch("app.api.v1.endpoints.auth._get_user_repo")
    def test_register_short_password(self, mock_get_repo, client):
        repo = mock_get_repo.return_value
        repo.get_by_email = AsyncMock(return_value=None)
        repo.create = AsyncMock(return_value=MagicMock(id=1, email="short@test.com"))

        resp = client.post("/api/v1/auth/register", json={
            "email": "short@test.com",
            "password": "ab",
        })
        assert resp.status_code == 201


# ── Login ────────────────────────────────────────────────────

class TestLogin:
    @patch("app.api.v1.endpoints.auth._create_refresh_token", new_callable=AsyncMock)
    @patch("app.api.v1.endpoints.auth._get_session_factory")
    @patch("app.api.v1.endpoints.auth._get_user_repo")
    def test_login_success(self, mock_get_repo, mock_get_sf, mock_create_rt, client):
        from app.core.security import hash_password
        user = MagicMock(
            id=1,
            email="user@test.com",
            hashed_password=hash_password("secret123"),
            is_active=True,
        )
        repo = mock_get_repo.return_value
        repo.get_by_email = AsyncMock(return_value=user)
        mock_create_rt.return_value = "refresh_token_value"

        resp = client.post("/api/v1/auth/login", data={
            "username": "user@test.com",
            "password": "secret123",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert data["refresh_token"] == "refresh_token_value"
        assert data["token_type"] == "bearer"

    @patch("app.api.v1.endpoints.auth._get_user_repo")
    def test_login_wrong_password(self, mock_get_repo, client):
        from app.core.security import hash_password
        user = MagicMock(
            id=1, email="user@test.com",
            hashed_password=hash_password("correct"),
            is_active=True,
        )
        repo = mock_get_repo.return_value
        repo.get_by_email = AsyncMock(return_value=user)

        resp = client.post("/api/v1/auth/login", data={
            "username": "user@test.com",
            "password": "wrong",
        })
        assert resp.status_code == 401

    @patch("app.api.v1.endpoints.auth._get_user_repo")
    def test_login_nonexistent_user(self, mock_get_repo, client):
        repo = mock_get_repo.return_value
        repo.get_by_email = AsyncMock(return_value=None)

        resp = client.post("/api/v1/auth/login", data={
            "username": "nobody@test.com",
            "password": "secret123",
        })
        assert resp.status_code == 401


# ── Refresh ──────────────────────────────────────────────────

class TestRefresh:
    @patch("app.api.v1.endpoints.auth._get_session_factory")
    @patch("app.api.v1.endpoints.auth._validate_refresh_token", new_callable=AsyncMock)
    @patch("app.api.v1.endpoints.auth._revoke_refresh_token", new_callable=AsyncMock)
    @patch("app.api.v1.endpoints.auth._get_user_repo")
    @patch("app.api.v1.endpoints.auth._create_refresh_token", new_callable=AsyncMock)
    def test_refresh_success(
        self, mock_create_rt, mock_get_repo, mock_revoke, mock_validate, mock_get_sf, client,
    ):
        mock_validate.return_value = 1
        user = MagicMock(id=1, email="user@test.com", is_active=True)
        mock_get_repo.return_value.get_by_id = AsyncMock(return_value=user)
        mock_create_rt.return_value = "new_refresh"

        resp = client.post("/api/v1/auth/refresh", json={
            "refresh_token": "valid_token",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert data["refresh_token"] == "new_refresh"

    @patch("app.api.v1.endpoints.auth._get_session_factory")
    @patch("app.api.v1.endpoints.auth._validate_refresh_token", new_callable=AsyncMock)
    def test_refresh_invalid_token(self, mock_validate, mock_get_sf, client):
        from fastapi import HTTPException
        mock_validate.side_effect = HTTPException(status_code=401, detail="Invalid refresh token")

        resp = client.post("/api/v1/auth/refresh", json={
            "refresh_token": "bad_token",
        })
        assert resp.status_code == 401


# ── Logout ───────────────────────────────────────────────────

class TestLogout:
    @patch("app.api.v1.endpoints.auth._get_session_factory")
    @patch("app.api.v1.endpoints.auth._revoke_refresh_token", new_callable=AsyncMock)
    def test_logout_success(self, mock_revoke, mock_get_sf, client):
        resp = client.post("/api/v1/auth/logout", json={
            "refresh_token": "some_token",
        })
        assert resp.status_code == 204
