"""Component CRUD endpoints."""

import json
import logging
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.core.auth import get_current_user
from app.db.sql.repositories.component import ComponentRepository

from ...schemas.request import ComponentCreate, ComponentUpdate
from ...schemas.response import ComponentResponse, MessageResponse

logger = logging.getLogger(__name__)

components_router = APIRouter(prefix="/components", tags=["components"])


def _get_repo(request: Request) -> ComponentRepository:
    return ComponentRepository(request.app.state.db_client)


def _to_component_response(comp) -> ComponentResponse:
    category_name = ""
    if getattr(comp, "category_ref", None) is not None:
        category_name = comp.category_ref.name or ""
    return ComponentResponse(
        id=comp.id,
        displayed_name=comp.displayed_name or "",
        description=comp.description or "",
        order=comp.order or 0,
        category_name=category_name,
        category_id=comp.category_id,
        name=comp.name,
        type=comp.type or "general",
        task=comp.task or "general",
        params=comp.params,
        inputs=comp.inputs,
        outputs=comp.outputs,
        api_call=comp.api_call or "",
    )


def _resolve_catalog_path() -> Path:
    current_file = Path(__file__).resolve()

    # Preferred location after catalog relocation.
    for parent in [current_file.parent] + list(current_file.parents):
        candidate = parent / "core" / "components.json"
        if candidate.exists():
            return candidate

    # Backward-compatible fallback location.
    for parent in [current_file.parent] + list(current_file.parents):
        candidate = parent / "components.json"
        if candidate.exists():
            return candidate

    raise FileNotFoundError("components.json not found")


@components_router.get("/", response_model=list[ComponentResponse])
async def list_components(
    request: Request, user: dict = Depends(get_current_user), skip: int = 0, limit: int = 200
):
    repo = _get_repo(request)
    components = await repo.get_all(skip=skip, limit=limit)
    return [_to_component_response(c) for c in components]


@components_router.post(
    "/", response_model=ComponentResponse, status_code=status.HTTP_201_CREATED
)
async def create_component(
    request: Request, body: ComponentCreate, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    comp = await repo.create(**body.model_dump())
    return _to_component_response(comp)


@components_router.post("/sync-catalog", response_model=MessageResponse)
async def sync_components_catalog(request: Request, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)

    try:
        catalog_path = _resolve_catalog_path()
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="components.json not found")

    try:
        with catalog_path.open("r", encoding="utf-8") as f:
            catalog_data = json.load(f)
    except (json.JSONDecodeError, OSError) as exc:
        raise HTTPException(status_code=400, detail=f"Failed to read catalog: {exc}")

    stats = await repo.sync_components_catalog(catalog_data)
    return MessageResponse(message="Catalog synced", data=stats)


@components_router.delete("/clear-all", response_model=MessageResponse)
async def clear_all_components(request: Request, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    count = await repo.clear_all()
    return MessageResponse(message=f"Cleared {count} components")


# ── Dynamic paths AFTER static paths ──


@components_router.get("/category/{category}", response_model=list[ComponentResponse])
async def get_components_by_category(
    request: Request, category: str, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    components = await repo.get_by_category(category)
    return [_to_component_response(c) for c in components]


@components_router.get("/{id}", response_model=ComponentResponse)
async def get_component(request: Request, id: int, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    component = await repo.get_by_id(id)
    if not component:
        raise HTTPException(status_code=404, detail="Component not found")
    return _to_component_response(component)


@components_router.put("/{id}", response_model=ComponentResponse)
async def update_component(
    request: Request, id: int, body: ComponentUpdate,
    user: dict = Depends(get_current_user),
):
    repo = _get_repo(request)
    result = await repo.update(id, **body.model_dump(exclude_unset=True))
    if not result:
        raise HTTPException(status_code=404, detail="Component not found")
    return _to_component_response(result)


@components_router.delete("/{id}", response_model=MessageResponse)
async def delete_component(request: Request, id: int, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    deleted = await repo.delete(id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Component not found")
    return MessageResponse(message="Component deleted")

