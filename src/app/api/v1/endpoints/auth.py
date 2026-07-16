"""Auth endpoints — register, login, refresh, logout."""

import logging
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.core.auth import create_access_token
from app.core.config import settings
from app.core.security import hash_password, verify_password
from app.db.sql.models.refresh_token import RefreshToken
from app.db.sql.repositories.user import UserRepository

from ...schemas.request import RefreshRequest, RegisterRequest
from ...schemas.response import RegisterResponse, TokenPairResponse

logger = logging.getLogger(__name__)

auth_router = APIRouter(prefix="/auth", tags=["auth"])


def _get_user_repo(request: Request) -> UserRepository:
    return UserRepository(request.app.state.db_client)


def _get_session_factory(request: Request) -> async_sessionmaker[AsyncSession]:
    return request.app.state.db_client


async def _create_refresh_token(
    sf: async_sessionmaker[AsyncSession],
    user_id: int,
) -> str:
    token_str = secrets.token_urlsafe(64)
    expires_at = datetime.now(timezone.utc) + timedelta(
        days=settings.refresh_token_expire_days,
    )
    async with sf() as session:
        # Revoke ALL existing tokens for this user via bulk update
        await session.execute(
            update(RefreshToken)
            .where(
                RefreshToken.user_id == user_id,
                RefreshToken.revoked.is_(False),
            )
            .values(revoked=True)
        )

        session.add(
            RefreshToken(
                token=token_str,
                user_id=user_id,
                expires_at=expires_at,
            )
        )
        await session.commit()
    return token_str


async def _revoke_refresh_token(
    sf: async_sessionmaker[AsyncSession],
    token_str: str,
) -> None:
    async with sf() as session:
        result = await session.execute(select(RefreshToken).where(RefreshToken.token == token_str))
        rt = result.scalar_one_or_none()
        if rt:
            rt.revoked = True
            await session.commit()


async def _validate_refresh_token(
    sf: async_sessionmaker[AsyncSession],
    token_str: str,
) -> int:
    async with sf() as session:
        result = await session.execute(select(RefreshToken).where(RefreshToken.token == token_str))
        rt = result.scalar_one_or_none()
        if not rt:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token",
            )
        if rt.revoked:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token has been revoked",
            )
        if rt.expires_at.replace(tzinfo=timezone.utc) < datetime.now(timezone.utc):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token has expired",
            )
        return rt.user_id


# ── Routes ───────────────────────────────────────────────────


@auth_router.post("/register", response_model=RegisterResponse, status_code=201)
async def register(body: RegisterRequest, request: Request):
    """Register a new user account."""
    repo = _get_user_repo(request)

    existing = await repo.get_by_email(body.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email already exists",
        )

    user = await repo.create(
        email=body.email,
        hashed_password=hash_password(body.password),
    )
    return RegisterResponse(id=user.id, email=user.email)


@auth_router.post("/login", response_model=TokenPairResponse)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), request: Request = None):
    """Authenticate and return an access + refresh token pair."""
    repo = _get_user_repo(request)

    user = await repo.get_by_email(form_data.username)
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is deactivated",
        )

    access_token = create_access_token(data={"sub": user.email, "user_id": user.id})

    sf = _get_session_factory(request)
    refresh_token = await _create_refresh_token(sf, user.id)

    return TokenPairResponse(access_token=access_token, refresh_token=refresh_token)


@auth_router.post("/refresh", response_model=TokenPairResponse)
async def refresh(body: RefreshRequest, request: Request):
    """Exchange a valid refresh token for a new token pair (rotation)."""
    sf = _get_session_factory(request)
    user_id = await _validate_refresh_token(sf, body.refresh_token)

    await _revoke_refresh_token(sf, body.refresh_token)

    repo = _get_user_repo(request)
    user = await repo.get_by_id(user_id)
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or deactivated",
        )

    access_token = create_access_token(data={"sub": user.email, "user_id": user.id})
    new_refresh = await _create_refresh_token(sf, user.id)

    return TokenPairResponse(access_token=access_token, refresh_token=new_refresh)


@auth_router.post("/logout", status_code=204)
async def logout(body: RefreshRequest, request: Request):
    """Revoke a refresh token (server-side logout)."""
    sf = _get_session_factory(request)
    await _revoke_refresh_token(sf, body.refresh_token)
