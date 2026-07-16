# AI-NO — Agent Guide

## Commands
```sh
ruff check src/app/engine    # Lint engine code
ruff check --fix <path>      # Auto-fix lint issues
pytest                       # Run tests (requires DB)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000  # Dev server
alembic upgrade head         # Apply DB migrations
```

## Architecture

`Project → Workflow → Node`. Workflows are tabs. Each workflow has its own subset of nodes and runs independently.

```
src/app/
  api/v1/endpoints/    # FastAPI route handlers
  core/                # Auth, config, middleware, security
  engine/              # Node execution engine
    base_node.py       # __init__ extracts metadata (incl. component_id), stores remaining in self.params
    exceptions.py      # Exception hierarchy for engine errors
    result.py          # Result type helper
    action_mixin.py    # ActionMixin shared by action nodes (resource resolution)
    model/             # Model, Fit, Predict, Evaluate
    preprocessing/     # Preprocessor, FitPreprocessor, Transform, FitTransform
    nets/              # Neural network layers
    other/             # DataLoader, Splitter, Joiner, etc.
    repositories/      # EnginePersistence (sync, Celery worker)
      execution.py     # EnginePersistence: save_result, load_data, load_node_meta, load_node_data
      db.py            # get_sync_session, NodeModel, ComponentModel (sync SQLAlchemy)
    schemas.py         # NodePayload, NodeContext (Pydantic DTOs)
    workflow_executor.py  # Background DAG-based execution
  db/sql/              # SQLAlchemy models + Alembic migrations
    models/
      user.py          # User model (email, hashed_password, is_active)
      refresh_token.py # RefreshToken model (DB-stored for revocation)
    repositories/      # Async CRUD (API layer)
      node.py          # NodeRepository: async CRUD + delete_with_files, clear_all, upsert_from_payload
      component.py     # ComponentRepository: async CRUD + clear_all
      user.py          # UserRepository: get_by_email()
  services/
    node_service.py    # NODE_CLASS_REGISTRY mapping, execute_node()
```

- **DataLoader**, **Splitter**, **FitTransform** now inherit from `BaseNode` (not standalone).
- `NodeCompatibilityMapper` is removed — API uses clean field names (`id`, `payload`, `type`, `component_id`, `in_ports`, `out_ports`, `gui_meta`).

## Two-Phase Repository Architecture

- **API layer** (async): `db/sql/repositories/node.py` — CRUD-only, never touches .pkl files
- **Engine layer** (sync): `engine/repositories/execution.py` — `.pkl` I/O + DB reads during execution
- **Celery worker** runs in a separate process with its own sync session (`get_sync_session()`)
- `EnginePersistence` is a stateless static-method class — each method creates its own sync session

## Key Conventions

- **Node PK** is single-column `id` (BigInteger, uuid-based)
- **Engine classes** use `ActionMixin` for resource resolution (action nodes)
- **Engine classes** are synchronous, wrapped in `asyncio.to_thread()` for async endpoints
- **`__init__` extracts metadata + stores inputs**; `execute()` performs DB reads + computation
- **`self.params`** stores remaining kwargs after BaseNode extracts metadata + user hyperparams merged with defaults
- **API fields**: `id`, `payload`, `type`, `component_id`, `in_ports`, `out_ports`, `gui_meta`. Legacy names (`node_id`, `node_data`, `cid`, `input_ports`, `output_ports`) are no longer used.
- **Model/Preprocessor** explicitly add `model_name`/`model_type`/`task` to `self.params` for DB persistence; `.node_params()` filters these out before passing to sklearn
- **`component_id`** = component template ID (string), looked up from `components` table by `node_name` in `load_handler`
- **`node_type`** in `payload_configs()` must match a key in `NODE_CLASS_REGISTRY`
- **`load_handler`** → `build_payload` → `EnginePersistence.save_result()` is the canonical save flow
- **workflow_id** is injected into every node's data by `WorkflowExecutor`

## Important Files

| File | Purpose |
|---|---|
| `app/engine/base_node.py` | Extracts metadata, delegates to subclass `payload_configs()` |
| `app/engine/model/model.py` | Model creation engine |
| `app/engine/preprocessing/preprocessor.py` | Preprocessor creation engine |
| `app/engine/repositories/execution.py` | EnginePersistence — sync persistence for .pkl + DB |
| `app/engine/workflow_executor.py` | Background DAG execution |
| `app/engine/schemas.py` | NodePayload, NodeContext DTOs |
| `app/engine/exceptions.py` | Error hierarchy |
| `app/engine/action_mixin.py` | Shared action resolution mixin |
| `app/engine/configs/const_.py` | NODES_ORDERING, DICT_NODES, MULTI_CHANNEL_NODES |
| `app/db/sql/repositories/node.py` | Async NodeRepository (CRUD, upsert_from_payload, delete_with_files) |
| `app/services/node_service.py` | NODE_CLASS_REGISTRY |
| `app/core/auth.py` | JWT authentication |
| `app/api/v1/endpoints/auth.py` | Register, login, refresh, logout endpoints |
| `app/api/v1/endpoints/models.py` | Model CRUD endpoints |
| `app/api/schemas/request/ml.py` | CreateModelRequest, PreprocessorRequest |

## Known Pitfalls

- `@property node_name` on Model/Preprocessor blocks `setattr` — BaseNode handles this with property check
- JWT auth required on all endpoints except `/health`
- Always pass `project_id` to creation endpoints or EnginePersistence skips DB save
- Re-running a workflow re-executes node constructors — each `Model.__init__` → `execute()` → `EnginePersistence.load_data()` + `EnginePersistence.save_result()` overwrites the .pkl
