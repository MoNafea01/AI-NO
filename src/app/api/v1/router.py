"""API v1 Router – aggregates all endpoint routers."""

from fastapi import APIRouter

from .endpoints.auth import auth_router
from .endpoints.components import components_router
from .endpoints.health import health_router
from .endpoints.io import io_router
from .endpoints.nodes import nodes_router
from .endpoints.projects import projects_router
from .endpoints.workflows import workflow_router

api_router = APIRouter(prefix="/v1", tags=["v1"])

api_router.include_router(auth_router)
api_router.include_router(health_router)
api_router.include_router(components_router)
api_router.include_router(projects_router)
api_router.include_router(workflow_router)
api_router.include_router(nodes_router)
api_router.include_router(io_router)
