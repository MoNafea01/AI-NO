"""Security utilities for API authentication, password hashing, and rate limiting."""

import logging

import bcrypt
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import APIKeyHeader
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from starlette.responses import JSONResponse

from .config import settings

logger = logging.getLogger(__name__)


# ============== Password Hashing ==============


def hash_password(plain: str) -> str:
    """Hash a plaintext password."""
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    """Verify a plaintext password against its hash."""
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))


# ============== Rate Limiting ==============


def get_client_identifier(request: Request) -> str:
    """Get client identifier for rate limiting (API key or IP)."""
    api_key = request.headers.get("X-API-Key")
    if api_key:
        return f"apikey:{api_key}"
    return get_remote_address(request)


limiter = Limiter(key_func=get_client_identifier)


def rate_limit_exceeded_handler(
    request: Request, exc: RateLimitExceeded
) -> JSONResponse:
    """Custom handler for rate limit exceeded errors."""
    return JSONResponse(
        status_code=status.HTTP_429_TOO_MANY_REQUESTS,
        content={
            "error": "Rate limit exceeded",
            "detail": str(exc.detail),
            "retry_after": (
                exc.detail.split(" per ")[1]
                if " per " in str(exc.detail)
                else "1 minute"
            ),
        },
    )


# ============== API Key Authentication ==============

API_KEY_HEADER = APIKeyHeader(name="X-API-Key", auto_error=False)


class APIKeyValidator:
    """API Key validation for protected endpoints."""

    def __init__(self, required: bool = True):
        self.required = required

    async def __call__(
        self,
        request: Request,
        api_key: str | None = Depends(API_KEY_HEADER),
    ) -> str | None:
        if settings.environment == "development" and not self.required:
            return api_key

        if not api_key:
            if self.required:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="API key is required",
                    headers={"WWW-Authenticate": "API-Key"},
                )
            return None

        valid_keys = self._get_valid_keys()
        if api_key not in valid_keys:
            if self.required:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid API key",
                    headers={"WWW-Authenticate": "API-Key"},
                )
            logger.warning(f"Invalid API key attempted: {api_key[:8]}...")
            return None

        return api_key

    def _get_valid_keys(self) -> set:
        keys = {settings.secret_key}
        if hasattr(settings, "api_keys") and settings.api_keys:
            keys.update(settings.api_keys)
        return keys


require_api_key = APIKeyValidator(required=True)
optional_api_key = APIKeyValidator(required=False)


# ============== Security Headers ==============


def add_security_headers(response):
    """Add security headers to response."""
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = (
        "max-age=31536000; includeSubDomains"
    )
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate"
    return response


# ============== Rate Limit Constants ==============

RATE_LIMIT_DEFAULT = "30/minute"
RATE_LIMIT_STRICT = "10/minute"
RATE_LIMIT_RELAXED = "60/minute"
