"""Custom middleware for the application."""

import time
import logging
from typing import Callable
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from .security import add_security_headers

logger = logging.getLogger(__name__)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Middleware to add security headers to all responses."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        response = await call_next(request)
        return add_security_headers(response)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log request/response information."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        start_time = time.time()

        logger.info(
            f"Request: {request.method} {request.url.path} "
            f"Client: {request.client.host if request.client else 'unknown'}"
        )

        response = await call_next(request)
        process_time = time.time() - start_time

        logger.info(
            f"Response: {request.method} {request.url.path} "
            f"Status: {response.status_code} "
            f"Time: {process_time:.3f}s"
        )

        response.headers["X-Process-Time"] = str(process_time)
        return response


class APIVersionMiddleware(BaseHTTPMiddleware):
    """Middleware to add API version header."""

    def __init__(self, app, version: str = "1.0"):
        super().__init__(app)
        self.version = version

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        response = await call_next(request)
        response.headers["X-API-Version"] = self.version
        return response
