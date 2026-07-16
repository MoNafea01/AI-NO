"""Project CRUD endpoints."""

from typing import Optional, List
from fastapi import APIRouter, Depends, Request, HTTPException, status

from app.core.auth import get_current_user

from ...schemas.request import ProjectCreate, ProjectUpdate, BulkProjectDelete
from ...schemas.response import ProjectResponse, ProjectDetailResponse, MessageResponse
from app.db.sql.repositories.project import ProjectRepository

projects_router = APIRouter(prefix="/projects", tags=["projects"])


def _get_repo(request: Request) -> ProjectRepository:
    return ProjectRepository(request.app.state.db_client)


@projects_router.get("/", response_model=List[ProjectResponse])
async def list_projects(
    request: Request,
    user: dict = Depends(get_current_user),
    model_name: Optional[str] = None,
    dataset_name: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    
    return await repo.get_filtered(
        user_id=user_id, model_name=model_name, dataset_name=dataset_name, skip=skip, limit=limit
    )


@projects_router.post(
    "/", response_model=ProjectResponse, status_code=status.HTTP_201_CREATED
)
async def create_project(
    request: Request, body: ProjectCreate, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    
    return await repo.create(**body.model_dump(), user_id=user_id)


@projects_router.post("/bulk-delete", response_model=MessageResponse)
async def bulk_delete_projects(
    request: Request, body: BulkProjectDelete, user: dict = Depends(get_current_user)
):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")

    count = await repo.delete_many(body.ids, user_id=user_id)
    return MessageResponse(message=f"Deleted {count} projects")


@projects_router.delete("/delete-empty", response_model=MessageResponse)
async def delete_empty_projects(request: Request, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    
    count = await repo.delete_empty_projects(user_id=user_id)
    return MessageResponse(message=f"Deleted {count} empty projects")

@projects_router.get("/models")
async def list_project_models(request: Request, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    
    models = await repo.get_distinct_models(user_id=user_id)
    return {"success": True, "models": models, "count": len(models)}


@projects_router.get("/datasets")
async def list_project_datasets(request: Request, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    
    datasets = await repo.get_distinct_datasets(user_id=user_id)
    return {"success": True, "datasets": datasets, "count": len(datasets)}

@projects_router.post("/multi-project-nodes")
async def multi_project_nodes(
    request: Request, body: list[dict], user: dict = Depends(get_current_user)
):
    """Create or update nodes across multiple projects."""
    import logging
    from app.db.sql.repositories.node import NodeRepository

    logger = logging.getLogger(__name__)
    results = {}
    for project_obj in body:
        project_id = project_obj.get("id")
        nodes = project_obj.get("content", [])
        if not project_id:
            continue
        project_name = project_obj.get("project_name", f"Project_{project_id}")
        project_description = project_obj.get("project_description", "No description provided")

        repo = _get_repo(request)
        project = await repo.get_by_id(project_id)
        if not project:
            project = await repo.create(
                name=project_name,
                description=project_description
            )
            project_id = project.id

        node_repo = NodeRepository(request.app.state.db_client)
        project_results = []
        for node_data in nodes:
            node_data.pop("project", None)
            node_data.pop("model", None)
            node_data["project_id"] = project_id
            if "node_id" in node_data:
                node_data["id"] = node_data.pop("node_id")
            try:
                created = await node_repo.upsert_from_payload(node_data)
                project_results.append({"id": created.id, "status": "created"})
            except Exception as e:
                logger.warning(
                    "Failed to create node %s in project %s: %s",
                    node_data.get("id"), project_id, e,
                )
                project_results.append({
                    "id": node_data.get("id"),
                    "status": "failed",
                    "error": str(e),
                })

        results[str(project_id)] = {
            "project_name": project_name,
            "nodes_processed": len(project_results),
            "results": project_results
        }

    return results


@projects_router.get("/{project_id}", response_model=ProjectDetailResponse)
async def get_project(
    request: Request,
    project_id: int,
    user: dict = Depends(get_current_user),
    include_nodes: int = 0,
):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    project = await repo.get_by_id(project_id, user_id=user_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    data = ProjectDetailResponse.model_validate(project)
    if include_nodes:
        from app.db.sql.repositories.node import NodeRepository

        node_repo = NodeRepository(request.app.state.db_client)
        nodes = await node_repo.get_by_project(project_id)
        data.content = [n.__dict__ for n in nodes]
    return data


@projects_router.put("/{project_id}", response_model=ProjectResponse)
async def update_project(
    request: Request, project_id: int, body: ProjectUpdate,
    user: dict = Depends(get_current_user),
):
    repo = _get_repo(request)
    
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    
    result = await repo.update(project_id, **body.model_dump(exclude_unset=True), user_id=user_id)
    if not result:
        raise HTTPException(status_code=404, detail="Project not found")
    return result


@projects_router.delete("/{project_id}", response_model=MessageResponse)
async def delete_project(request: Request, project_id: int, user: dict = Depends(get_current_user)):
    repo = _get_repo(request)
    user_id = user.get("id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user session")
    deleted = await repo.delete(project_id, user_id=user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Project not found")
    return MessageResponse(message="Project deleted")
