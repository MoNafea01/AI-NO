# AI-NO Migration Plan: Django → FastAPI

## Mission

Migrate the ML workflow backend from `project/` (Django REST Framework) to `src/` (FastAPI). Fix existing bugs, implement missing endpoints, and add a parallel execution engine with hash-based caching.

---

## Phase 1: Fix Critical Bugs

### 1.1 Fix io.py save_node/load_node
- **Files**: `src/app/api/v1/endpoints/io.py`, `src/app/services/node_service.py`
- **Problem**: `io.py:19` calls `service.execute_node("save_node", ...)` but `"save_node"` is NOT in `NODE_CLASS_REGISTRY`. Same for `"load_node"`.
- **Fix**: Use `NodeService.save_node()` and `NodeService.load_node()` static methods instead
- **Also**: Fix `NodeService.save_node()` signature — it expects `(node_id, project_id)` but io.py passes the full body

### 1.2 Add io/load-template endpoint
- **Old Django**: `GET /api/template/` → `NodeTemplateLoaderAPIView`
- **New**: Add `POST /api/v1/io/load-template` endpoint
- Wire to `NodeService.execute_node("load_template", ...)`
- `"load_template"` IS in registry but maps to `NodeTemplateLoader` — check if it works

### 1.3 Wrap sync engine calls
- **Problem**: `NodeService.execute_node()` is synchronous. Called directly from async endpoints blocks the event loop.
- **Fix**: Wrap in `asyncio.to_thread()` or `run_in_executor()`
- Engine classes use scikit-learn/numpy (CPU-bound), so this is necessary for proper async behavior

### 1.4 Fix save_template return type
- **Problem**: `io/save-template` endpoint doesn't return proper response
- **Fix**: verify `NodeTemplateSaver` works end-to-end

---

## Phase 2: Port Missing Django Endpoints

### 2.1 Projects — models/datasets listing
- **Old**: `ProjectModelsAPIView` (GET `/api/project-models/`), `ProjectDatasetsAPIView` (GET `/api/project-datasets/`)
- **New**: Add to `projects_router`:
  - `GET /api/v1/projects/models` — SELECT DISTINCT model FROM projects
  - `GET /api/v1/projects/datasets` — SELECT DISTINCT dataset FROM projects
- **Repository**: Add `get_distinct_models()` and `get_distinct_datasets()` to `ProjectRepository`

### 2.2 Multi-project nodes
- **Old**: `MultiProjectNodeAPIView` (POST `/api/multi-project-nodes/`)
- **New**: `POST /api/v1/projects/multi-project-nodes`
- Accepts `[{id, project_name?, project_description?, content: [nodes]}]`
- Creates/updates nodes per project

### 2.3 Clear all nodes (global)
- **Old**: `ClearNodesAPIView` (DELETE `/api/clear_nodes/`)
- **New**: `DELETE /api/v1/nodes/clear-all`
- Calls `ClearAllNodes()(project_id=project_id)` — already exists in engine

### 2.4 Clear all components
- **Old**: `ClearComponentsAPIView` (DELETE `/api/clear_components/`)
- **New**: `DELETE /api/v1/components/clear-all`
- Calls `ClearAllNodes()('components')` — already exists in engine

### 2.5 Upload components via Excel
- **Old**: `ExcelUploadAPIView` (POST `/api/upload_excel/`)
- **New**: `POST /api/v1/components/upload-excel`
- Accept multipart file upload, parse with pandas, create Component DB rows

### 2.6 Update components catalog
- **Old**: `UpdateComponentsAPIView` (PUT `/api/update_components/`)
- **New**: `PUT /api/v1/components/update`
- Accepts `file_path`, calls clear + re-upload

---

## Phase 3: Implement Stubs

### 3.1 Export project
- **Old**: `ExportProjectAPIView` (POST `/api/export-project/`)
- **New**: `POST /api/v1/io/export-project` (currently returns "not yet implemented")
- **Logic**: Load project + nodes → serialize JSON → optionally convert to AINOPRJ (encrypted) via `jsonAinoConverter.py`

### 3.2 Import project
- **Old**: `ImportProjectAPIView` (GET `/api/import-project/`)
- **New**: `POST /api/v1/io/import-project`
- **Logic**: Read JSON/AINOPRJ file → convert if needed → create/update nodes

### 3.3 Celery workflow task
- **File**: `src/app/tasks/workflow.py`
- Currently returns placeholder
- Wire to engine for background workflow execution

---

## Phase 4: Schema & Model Alignment

### 4.1 Node model compatibility
- Add field mapping layer in `NodeRepository.create()` / `NodeRepository.update()`
- Map: `node_type` → `type`, `input_ports` → `in_ports`, `output_ports` → `out_ports`
- Store legacy fields (`message`, `displayed_name`, `cid`, `location_x/y`, `children`, `parent`) in `gui_meta`
- Add backward-compatible response serializer that reconstructs old field names from `gui_meta`

### 4.2 Generate Alembic migration
- Run `alembic revision --autogenerate -m "initial"`
- Review and fix the generated migration

### 4.3 Fix requirements.txt
- Currently a binary file (corrupted)
- Recreate from actual imports in `src/`

---

## Phase 5: Parallel Workflow Execution Engine 🆕

### 5.1 New DB tables
```sql
CREATE TABLE workflow_executions (
    id SERIAL PRIMARY KEY,
    project_id INTEGER REFERENCES projects(id),
    status VARCHAR(50) DEFAULT 'pending',  -- pending, running, completed, failed
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE TABLE execution_queue (
    id SERIAL PRIMARY KEY,
    execution_id INTEGER REFERENCES workflow_executions(id),
    node_id BIGINT NOT NULL,
    project_id INTEGER NOT NULL,
    topological_order INTEGER NOT NULL,
    no_of_children INTEGER DEFAULT 0,
    remaining_children_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',  -- pending, running, completed, failed
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(execution_id, node_id, project_id)
);

CREATE TABLE execution_dependencies (
    id SERIAL PRIMARY KEY,
    execution_id INTEGER REFERENCES workflow_executions(id),
    node_id BIGINT NOT NULL,
    depends_on_node_id BIGINT NOT NULL,
    UNIQUE(execution_id, node_id, depends_on_node_id)
);
```

### 5.2 DAG Resolver (Kahn's Algorithm)
- Input: list of node_ids + their `in_ports`/`out_ports` connections
- Build adjacency list from port connections
- Compute in-degree for each node
- Run Kahn's Algorithm to get topological order layers
- Each layer = set of nodes with same order (parallelizable)

### 5.3 Parallel Executor
- For each topological layer, execute all nodes concurrently
- Use `asyncio.gather()` or Celery task groups (canvas)
- After layer completes, check `remaining_children_count` for downstream nodes
- When a node's `remaining_children_count` hits 0, it's eligible for cleanup

### 5.4 Auto-cleanup
- After all dependents of a node have executed, delete its `.pkl` from disk and its DB row
- This keeps storage bounded

---

## Phase 6: Hash-Based Execution Caching 🆕

### 6.1 New DB table
```sql
CREATE TABLE execution_cache (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    node_id BIGINT NOT NULL,
    node_type VARCHAR(255) NOT NULL,
    hash_value VARCHAR(64) NOT NULL,        -- SHA-256
    params_hash VARCHAR(64) NOT NULL,
    parent_hashes TEXT,                       -- JSON array of parent hashes
    result_path VARCHAR(500) NOT NULL,        -- path to cached .pkl
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(project_id, node_id)
);
```

### 6.2 Hash computation
```
H_node = SHA256(params_json + sort(parent_hashes))
```
Where:
- `params_json` = canonical JSON of the node's parameters
- `parent_hashes` = array of H_parent for each upstream node

### 6.3 Cache integration in NodeService
- Before `execute_node()` creates an engine class, compute H_node
- Query `execution_cache` for matching hash
- Hit: load result from cached path, skip processing
- Miss: execute normally, store result + hash
- Eviction: keep last 10 unique hashes per node_type per project

### 6.4 Undo/Redo
- Store execution history: `execution_history` table
- Each entry: (project_id, node_id, hash_value, result_path, timestamp)
- Undo: restore previous hash's result path
- Redo: advance to next hash

---

## Phase 7: Testing & Infrastructure

### 7.1 Integration tests
- Test CRUD endpoints with test DB
- Test ML operations (data_loader, fit_model, predict, evaluate)
- Test export/import round-trip
- Test new execution engine
- Test caching layer

### 7.2 Lint & typecheck
- Run `ruff check src/`
- Fix any issues

### 7.3 Full endpoint parity verification
- Cross-reference every old Django URL against new FastAPI endpoints
- Ensure all field names, response formats, and status codes match

---

## File Reference

| File | Purpose |
|------|---------|
| `src/app/main.py` | FastAPI app, lifespan, middleware |
| `src/app/api/v1/router.py` | Aggregates all endpoint routers |
| `src/app/api/v1/endpoints/projects.py` | Project CRUD |
| `src/app/api/v1/endpoints/nodes.py` | Node CRUD |
| `src/app/api/v1/endpoints/components.py` | Component CRUD + catalog sync |
| `src/app/api/v1/endpoints/data.py` | Data operations |
| `src/app/api/v1/endpoints/models.py` | ML model operations |
| `src/app/api/v1/endpoints/preprocessors.py` | Preprocessor operations |
| `src/app/api/v1/endpoints/nn.py` | Neural network operations |
| `src/app/api/v1/endpoints/io.py` | I/O operations (save/load/export/import) |
| `src/app/api/v1/endpoints/health.py` | Health check |
| `src/app/api/schemas/request/` | Pydantic request models |
| `src/app/api/schemas/response/__init__.py` | Pydantic response models |
| `src/app/services/node_service.py` | Orchestration + node registry |
| `src/app/engine/base_node.py` | Base engine node class |
| `src/app/engine/__init__.py` | Engine exports (DataLoader, Model, etc.) |
| `src/app/engine/repositories/` | Node save/load/update/delete |
| `src/app/db/sql/models/` | SQLAlchemy models |
| `src/app/db/sql/repositories/` | Async CRUD repositories |
| `src/app/core/components.json` | Component catalog |
| `src/app/core/config.py` | Pydantic settings |
| `src/app/tasks/workflow.py` | Celery workflow task |
| `project/ai_operations/views.py` | OLD Django views (source of truth) |
| `project/ai_operations/urls.py` | OLD Django URL patterns |
| `project/ai_operations/models.py` | OLD Django models |
| `project/ai_operations/serializers.py` | OLD Django serializers |
