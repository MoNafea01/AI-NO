# AI-NO: Node-Based Machine Learning Workflow System

AI-NO is a machine learning workflow platform that lets users build, manage, and execute ML pipelines through a visual node-based editor backed by a FastAPI + Celery architecture.

## Overview

- **Frontend**: Flutter desktop app with a visual node editor (drag-and-drop)
- **Backend**: FastAPI (async) + SQLAlchemy + Alembic + PostgreSQL
- **Engine**: Synchronous ML execution layer (scikit-learn, TensorFlow/Keras)
- **Task Queue**: Celery + RabbitMQ + Redis for background workflow execution
- **Infrastructure**: Docker Compose (FastAPI, Celery worker, Celery beat, Flower, PostgreSQL, RabbitMQ, Redis, Qdrant, Nginx)

## Architecture

```
┌──────────────┐     HTTP      ┌──────────────┐     Celery     ┌──────────────┐
│  Flutter GUI │ ───────────►  │   FastAPI    │ ────────────►  │ Celery Worker│
│  (Node Ed.)  │               │  (async API) │               │  (sync exec) │
└──────────────┘               └──────────────┘               └──────┬───────┘
                                                                     │
                                          ┌──────────────────────────┤
                                          │                          │
                                     ┌────▼─────┐            ┌──────▼──────┐
                                     │PostgreSQL│            │  .pkl files  │
                                     │  (DB)    │            │  (artifacts) │
                                     └──────────┘            └─────────────┘
```

### Two-Phase Repository Architecture

- **API layer** (async): `db/sql/repositories/` — CRUD, never touches `.pkl` files
- **Engine layer** (sync): `engine/repositories/execution.py` — `.pkl` I/O + DB reads during execution
- Each Celery worker thread creates its own sync DB session via `get_sync_session()`

## Project Structure

```
src/app/
├── api/v1/endpoints/         # FastAPI route handlers
│   ├── auth.py               # Register, login, refresh, logout
│   ├── nodes.py              # Unified node CRUD (POST /v1/nodes/)
│   ├── workflows.py          # Workflow CRUD + run trigger
│   ├── components.py         # Component catalog sync
│   ├── projects.py           # Project management
│   ├── io.py                 # Import/export (.ainoprj)
│   ├── health.py             # Health check
│   └── _helpers.py           # Shared node creation logic
├── core/                     # Auth, config, middleware, security
│   ├── auth.py               # JWT authentication
│   ├── config.py             # Settings from env vars
│   ├── components.json       # Component definitions (source of truth)
│   ├── middleware.py          # CORS, rate limiting, security headers
│   └── security.py           # Password hashing, JWT tokens
├── engine/                   # ML execution engine
│   ├── base_node.py          # BaseNode — extracts metadata, stores params
│   ├── schemas.py            # NodePayload, NodeContext DTOs
│   ├── exceptions.py         # Engine error hierarchy
│   ├── validation.py         # Node parameter validation
│   ├── action_mixin.py       # ActionMixin for action nodes
│   ├── dag.py                # DAG builder, topological sort, hashing
│   ├── utils.py              # NodeNameHandler, PayloadBuilder
│   ├── configs/
│   │   ├── registry.py       # NODE_REGISTRY — single source of truth
│   │   ├── defaults.py       # sklearn class refs + default params
│   │   └── const_.py         # SAVING_DIR, base_dir
│   ├── model/                # Model nodes
│   │   ├── model.py          # Model creation (sklearn instantiation)
│   │   ├── fit.py            # ModelFitter (sklearn .fit())
│   │   ├── predict.py        # ModelPredictor (sklearn .predict())
│   │   └── evaluator.py      # Evaluator (metrics)
│   ├── preprocessing/        # Preprocessor nodes
│   │   ├── preprocessor.py   # Preprocessor creation
│   │   ├── fit.py            # FitPreprocessor
│   │   ├── transform.py      # Transform
│   │   └── fit_transform.py  # FitTransform (multi-output)
│   ├── nets/                 # Neural network nodes
│   │   ├── base_layer.py     # BaseLayer (Keras layer base)
│   │   ├── sequential.py     # SequentialNet (chain builder)
│   │   ├── compile.py        # CompileModel
│   │   ├── fit.py            # FitNet (Keras .fit())
│   │   ├── dnn_layers.py     # Dense, Dropout
│   │   └── cnn_layers.py     # Conv2D, MaxPooling2D
│   ├── other/
│   │   ├── dataLoader.py     # DataLoader (datasets, CSV, pkl)
│   │   ├── train_test_split.py
│   │   └── custom.py         # Joiner, Splitter, Template nodes
│   └── repositories/
│       ├── execution.py      # EnginePersistence (sync .pkl + DB)
│       └── db.py             # get_sync_session, NodeModel, ComponentModel
├── db/sql/
│   ├── models/               # SQLAlchemy ORM models
│   │   ├── user.py           # User (email, hashed_password)
│   │   ├── project.py        # Project
│   │   ├── node.py           # Node (in_ports, out_ports, gui_meta as JSONB)
│   │   ├── workflow.py       # Workflow, WorkflowRun, WorkflowStep
│   │   ├── workflow_snapshot.py  # Versioned workflow snapshots
│   │   ├── component.py      # Component (category_id FK)
│   │   ├── execution_cache.py
│   │   └── refresh_token.py  # RefreshToken (DB-stored for revocation)
│   └── repositories/         # Async CRUD (API layer)
│       ├── node.py           # NodeRepository (CRUD, upsert, delete_with_files)
│       ├── component.py      # ComponentRepository (sync catalog)
│       └── user.py           # UserRepository
├── services/
│   └── node_service.py       # NODE_CLASS_REGISTRY + execute_node()
├── tasks/
│   └── workflow.py           # Celery task: DAG execution with ThreadPoolExecutor
└── celery_app.py             # Celery app configuration
```

## Node System

### Port-Based Connections

Nodes communicate through **port references** instead of parent/child relationships:

```json
"in_ports": {"Model": "1644852298488396063:0:0", "X": "954172899044432124:0:0", "y": "954172899044432124:0:1"}
"out_ports": {"Fitted Model": "3418586186198404966:0:0"}
```

Format: `"node_id:group_idx:port_idx"` — port names must match `components.json` definitions exactly.

### Unified Node Endpoint

All node types are created through a single endpoint:

```
POST /api/v1/nodes/?project_id={id}&workflow_id={id}
```

- `node_name`: Node name (e.g., `"data_loader"`, `"linear_regression"`)
- `params`: Node-specific data (dataset name, model params, etc.)
- `in_ports` / `out_ports`: Port connections (dict)
- `gui_node_data`: Frontend metadata (position, display name, selected output)

The `type` field is resolved against `NODE_REGISTRY` which maps to the correct engine class.

### Node Registry

`engine/configs/registry.py` is the single source of truth for all node types:

```python
NODE_REGISTRY = {
    "ridge": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {"alpha": 1.0},
        "metadata": {"model_name": "ridge", "model_type": "linear_models", "task": "regression"},
    },
    # ... 50+ node types
}
```

Each entry defines: `node_type` (dispatch key), `category`, `task`, `defaults` (hyperparams), `metadata` (DB persistence fields).

### Execution Flow

1. Client sends `POST /v1/nodes/` with `node_name` and `in_ports`/`out_ports`
2. `_helpers.py` resolves `node_name` → `NODE_REGISTRY` → `node_type` + `metadata`
3. Node is saved to DB with `in_ports`/`out_ports` (no execution yet)
4. Client triggers workflow via `POST /workflows/{id}/run`
5. `WorkflowExecutor` builds DAG from port connections, runs nodes in topological order
6. Each node's `execute()` loads upstream data via `EnginePersistence.load_port()`
7. Results saved to `.pkl` files + DB via `EnginePersistence.save_result()`

### Engine Execution

```python
# services/node_service.py
NODE_CLASS_REGISTRY = {
    "data_loader": DataLoader,
    "create_model": Model,
    "fit_model": FitModel,
    "predict": Predict,
    "evaluate": Evaluate,
    "create_preprocessor": Preprocessor,
    "fit_preprocessor": FitPreprocessor,
    "transform": Transform,
    "fit_transform": FitTransform,
    "create_input": InputLayer,
    "dense": DenseLayer,
    "conv2d": Conv2DLayer,
    "sequential": SequentialNet,
    "compile": CompileModel,
    "fit_net": FitNet,
    # ... more
}
```

Each engine class extends `BaseNode`. The `__init__` extracts metadata (`project_id`, `workflow_id`, `in_ports`, `out_ports`) and stores remaining kwargs as `self.params`. The `execute()` method performs the actual work.

### Node ID Generation

Node IDs use `uuid.uuid4()` (random, not time-based) to prevent collisions in Docker containers where VM clock regression can cause `uuid.uuid1()` duplicates.

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Create user account |
| POST | `/api/v1/auth/login` | Login (returns access + refresh tokens) |
| POST | `/api/v1/auth/refresh` | Refresh access token (revokes old refresh) |
| POST | `/api/v1/auth/logout` | Revoke refresh token |

### Nodes
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/nodes/` | Create any node type (unified) |
| GET | `/api/v1/nodes/{id}` | Get node |
| PATCH | `/api/v1/nodes/{id}` | Update node (merges gui_meta, selected_output) |
| DELETE | `/api/v1/nodes/{id}` | Delete node + .pkl files |
| DELETE | `/api/v1/nodes/` | Clear all nodes in project/workflow |

### Workflows
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/workflows/` | Create workflow |
| GET | `/api/v1/workflows/` | List workflows |
| PATCH | `/api/v1/workflows/{id}` | Update workflow |
| DELETE | `/api/v1/workflows/{id}` | Delete workflow |
| POST | `/api/v1/workflows/{id}/run` | Trigger background execution |
| POST | `/api/v1/workflows/{id}/clone` | Clone workflow (new node IDs + port remapping) |
| GET | `/api/v1/workflows/{id}/snapshots` | List snapshots |
| POST | `/api/v1/workflows/{id}/snapshots` | Save snapshot |
| POST | `/api/v1/workflows/{id}/snapshots/restore` | Restore snapshot (new node IDs + port remapping) |

### Components
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/components/` | List components |
| GET | `/api/v1/components/{id}` | Get component |
| POST | `/api/v1/components/sync-catalog` | Sync from `components.json` |
| PUT | `/api/v1/components/{id}` | Update component |

### Projects & I/O
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/projects/` | Create project |
| GET | `/api/v1/projects/` | List projects |
| POST | `/api/v1/io/export` | Export project to `.ainoprj` |
| POST | `/api/v1/io/import` | Import `.ainoprj` file |

## Docker Deployment

```bash
cd src/docker
docker compose up -d
```

**Services:**
| Service | Port | Purpose |
|---------|------|---------|
| fastapi | 8000 | API server |
| celery-worker | — | Background task execution |
| celery-beat | — | Periodic task scheduler |
| flower | 5555 | Celery monitoring |
| postgres | 5432 | Database |
| rabbitmq | 5672/15672 | Message broker |
| redis | 6379 | Cache + result backend |
| qdrant | 6333/6334 | Vector database |
| nginx | 8080 | Reverse proxy |

## Development

### Setup

```bash
cd src
pip install -e ".[dev]"
```

### Commands

```bash
# Lint
ruff check src/app/engine

# Auto-fix
ruff check --fix <path>

# Tests (requires running DB)
pytest

# Dev server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Apply migrations
alembic upgrade head

# Celery worker
celery -A celery_app worker --loglevel=info -Q default,workflow_queue
```

## Key Conventions

- **`in_ports`/`out_ports`**: `dict[str, str]` — keys are port names from `components.json`, values are `"node_id:group_idx:port_idx"`
- **Port names** are PascalCase with spaces (`"Model"`, `"Fitted Model"`, `"Data"`, `"X"`, `"y"`)
- **`component_id`** is resolved from DB first, falls back to `components.json` directly
- **`type`** in the API payload maps to `NODE_REGISTRY` → `node_type` → `NODE_CLASS_REGISTRY`
- **`selected_output`** stored in `params` for multi-output nodes (e.g., DataLoader has 3 output groups)
- **`gui_meta`** stores `location_x`, `location_y`, `displayed_name` (no `children`/`parent`)
- **Engine classes** are synchronous, called via `asyncio.to_thread()` for async endpoints
- **`self.params`** contains remaining kwargs after BaseNode extracts metadata + user hyperparams merged with defaults
- **Refresh tokens**: login/refresh revokes ALL previous non-revoked tokens (one active token per user)
