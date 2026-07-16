# Unified Node CRUD + Port-Based Connections

> **Status**: Plan ready for implementation
> **Scope**: ~25 files, 4 phases
> **Prerequisite**: All 132 tests passing, 63 lint warnings (cosmetic)

---

## Goal

Replace 22+ separate node-creation endpoints with a **single `POST /v1/nodes/`** endpoint. Client sends `node_name`, system auto-derives everything. Replace `children`/`parent` with port-based `in_ports`/`out_ports` dicts. Full engine refactor to use port refs for data resolution.

---

## Design Decisions

| Decision | Choice |
|---|---|
| Endpoint design | Single `POST /v1/nodes/` with `node_name` |
| `in_ports` format | `dict[str, str]` keyed by port name: `{"X": "dl_id:0:0", "y": "dl_id:0:1"}` — remote output ports this node receives from |
| `out_ports` format | `dict[str, str]` keyed by port name: `{"X_train": "splitter_id:0:0"}` — remote input ports this node sends to |
| Port ID format | `node_id:group_idx:port_idx` (e.g., `123:0:0`) |
| `children`/`parent` | **DROPPED** — derived from port dicts, not stored |
| Registry source | `nodes_info.py` + `defaults.py` → single `registry.py` |
| Engine refactor | **Full now** — engine classes accept `in_ports` dict |
| I/O endpoints | Node-level (save/load/template) → `nodes.py`; export/import → stays `io.py` |
| Old endpoints | **Deleted entirely** |
| Who generates port IDs | **Client** (from `components.json` definitions) |
| `selected_output` field | Stored in `params` on the node — tells engine which output group to produce |

---

## Architecture Overview

### Unified Request

```json
POST /v1/nodes/
{
  "node_name": "ridge",
  "params": {"alpha": 2.0},
  "in_ports": {"X": "dl_id:0:0", "y": "dl_id:0:1"},
  "out_ports": {},
  "selected_output": null,
  "project_id": 1,
  "workflow_id": 1,
  "location_x": 100,
  "location_y": 200,
  "displayed_name": "My Ridge"
}
```

### Create Flow

1. `node_name` → `NODE_REGISTRY` lookup → `node_type`, `category`, `task`, `defaults`, `metadata`
2. `final_params = {**defaults, **user_params, **metadata}`
3. `validate_params(node_type, final_params)`
4. Resolve `component_id` from components table
5. Create node: `type=node_type, task=task, params=final_params, in_ports=..., out_ports=...`

### Port System

**DataLoader → Splitter (X and y):**

```
DataLoader:
  in_ports: {}
  out_ports: {"X": "splitter_id:0:0", "y": "splitter_id:0:1"}

Splitter:
  in_ports: {"X": "dl_id:0:0", "y": "dl_id:0:1"}
  out_ports: {}
```

Derived (no longer stored):
- `children` = unique node_ids from `out_ports` values → `[splitter_id]`
- `parent` = unique node_ids from `in_ports` values → `[dl_id]`

### Engine Execution with Ports

**FitModel (receives model, X, y from different nodes):**

```python
class FitModel(BaseNode):
    def execute(self):
        in_ports = self.in_ports or {}
        model = EnginePersistence.load_port(in_ports["model"], self.project_id)
        X = EnginePersistence.load_port(in_ports["X"], self.project_id)
        y = EnginePersistence.load_port(in_ports["y"], self.project_id)
        # ... fit model
```

**`load_port("dl_id:0:0")` flow:**
1. Parse → `node_id=dl_id, group_idx=0, port_idx=0`
2. Load node result from DB
3. Result is `{"0:0": X_data, "0:1": y_data}` (port-keyed dict)
4. Extract `result["0:0"]` → return X_data

---

## Phase 1: Unified Node Registry

### Create `app/engine/configs/registry.py`

Single source of truth for `node_name` → engine dispatch + defaults + metadata.

```python
NODE_REGISTRY = {
    # ── Models ──
    "ridge": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {"alpha": 1.0},
        "metadata": {"model_name": "ridge", "model_type": "linear_models", "task": "regression"},
    },
    "lasso": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {"alpha": 1.0},
        "metadata": {"model_name": "lasso", "model_type": "linear_models", "task": "regression"},
    },
    "elastic_net": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {"alpha": 1.0, "l1_ratio": 0.5},
        "metadata": {"model_name": "elastic_net", "model_type": "linear_models", "task": "regression"},
    },
    "linear_regression": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {},
        "metadata": {"model_name": "linear_regression", "model_type": "linear_models", "task": "regression"},
    },
    "sgd_regression": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {"penalty": "l2"},
        "metadata": {"model_name": "sgd_regression", "model_type": "linear_models", "task": "regression"},
    },
    "svr": {
        "node_type": "create_model",
        "category": "svm",
        "task": "regression",
        "defaults": {"C": 1.0, "kernel": "rbf"},
        "metadata": {"model_name": "svr", "model_type": "svm", "task": "regression"},
    },
    "decision_tree_regressor": {
        "node_type": "create_model",
        "category": "tree",
        "task": "regression",
        "defaults": {"max_depth": None},
        "metadata": {"model_name": "decision_tree_regressor", "model_type": "tree", "task": "regression"},
    },
    "random_forest_regressor": {
        "node_type": "create_model",
        "category": "tree",
        "task": "regression",
        "defaults": {"n_estimators": 100, "max_depth": None},
        "metadata": {"model_name": "random_forest_regressor", "model_type": "tree", "task": "regression"},
    },
    "gradient_boosting_regressor": {
        "node_type": "create_model",
        "category": "tree",
        "task": "regression",
        "defaults": {},
        "metadata": {"model_name": "gradient_boosting_regressor", "model_type": "tree", "task": "regression"},
    },
    "adaboost_regressor": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "regression",
        "defaults": {},
        "metadata": {"model_name": "adaboost_regressor", "model_type": "ensemble", "task": "regression"},
    },
    "bagging_regressor": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "regression",
        "defaults": {},
        "metadata": {"model_name": "bagging_regressor", "model_type": "ensemble", "task": "regression"},
    },
    "knn_regressor": {
        "node_type": "create_model",
        "category": "knn",
        "task": "regression",
        "defaults": {"n_neighbors": 5},
        "metadata": {"model_name": "knn_regressor", "model_type": "knn", "task": "regression"},
    },
    "gaussian_nb": {
        "node_type": "create_model",
        "category": "naive_bayes",
        "task": "classification",
        "defaults": {},
        "metadata": {"model_name": "gaussian_nb", "model_type": "naive_bayes", "task": "classification"},
    },
    "bernoulli_nb": {
        "node_type": "create_model",
        "category": "naive_bayes",
        "task": "classification",
        "defaults": {},
        "metadata": {"model_name": "bernoulli_nb", "model_type": "naive_bayes", "task": "classification"},
    },
    "multinomial_nb": {
        "node_type": "create_model",
        "category": "naive_bayes",
        "task": "classification",
        "defaults": {},
        "metadata": {"model_name": "multinomial_nb", "model_type": "naive_bayes", "task": "classification"},
    },
    "sgd_classifier": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "classification",
        "defaults": {"penalty": "l2"},
        "metadata": {"model_name": "sgd_classifier", "model_type": "linear_models", "task": "classification"},
    },
    "ridge_classifier": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "classification",
        "defaults": {"alpha": 1.0},
        "metadata": {"model_name": "ridge_classifier", "model_type": "linear_models", "task": "classification"},
    },
    "logistic_regression": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "classification",
        "defaults": {"penalty": "l2", "C": 1.0},
        "metadata": {"model_name": "logistic_regression", "model_type": "linear_models", "task": "classification"},
    },
    "svc": {
        "node_type": "create_model",
        "category": "svm",
        "task": "classification",
        "defaults": {"C": 1.0, "kernel": "rbf"},
        "metadata": {"model_name": "svc", "model_type": "svm", "task": "classification"},
    },
    "decision_tree_classifier": {
        "node_type": "create_model",
        "category": "tree",
        "task": "classification",
        "defaults": {"max_depth": None},
        "metadata": {"model_name": "decision_tree_classifier", "model_type": "tree", "task": "classification"},
    },
    "random_forest_classifier": {
        "node_type": "create_model",
        "category": "tree",
        "task": "classification",
        "defaults": {"n_estimators": 100, "max_depth": None},
        "metadata": {"model_name": "random_forest_classifier", "model_type": "tree", "task": "classification"},
    },
    "gradient_boosting_classifier": {
        "node_type": "create_model",
        "category": "tree",
        "task": "classification",
        "defaults": {},
        "metadata": {"model_name": "gradient_boosting_classifier", "model_type": "tree", "task": "classification"},
    },
    "adaboost_classifier": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "classification",
        "defaults": {},
        "metadata": {"model_name": "adaboost_classifier", "model_type": "ensemble", "task": "classification"},
    },
    "bagging_classifier": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "classification",
        "defaults": {},
        "metadata": {"model_name": "bagging_classifier", "model_type": "ensemble", "task": "classification"},
    },
    "knn_classifier": {
        "node_type": "create_model",
        "category": "knn",
        "task": "classification",
        "defaults": {"n_neighbors": 5},
        "metadata": {"model_name": "knn_classifier", "model_type": "knn", "task": "classification"},
    },

    # ── Preprocessors ──
    "standard_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"with_mean": True, "with_std": True},
        "metadata": {"preprocessor_name": "standard_scaler", "preprocessor_type": "scaler", "task": "preprocessing"},
    },
    "maxabs_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {},
        "metadata": {"preprocessor_name": "maxabs_scaler", "preprocessor_type": "scaler", "task": "preprocessing"},
    },
    "normalizer": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"norm": "l2"},
        "metadata": {"preprocessor_name": "normalizer", "preprocessor_type": "scaler", "task": "preprocessing"},
    },
    "minmax_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"feature_range": [0, 1]},
        "metadata": {"preprocessor_name": "minmax_scaler", "preprocessor_type": "scaler", "task": "preprocessing"},
    },
    "robust_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"quantile_range": [25.0, 75.0]},
        "metadata": {"preprocessor_name": "robust_scaler", "preprocessor_type": "scaler", "task": "preprocessing"},
    },
    "label_encoder": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {"preprocessor_name": "label_encoder", "preprocessor_type": "encoder", "task": "preprocessing"},
    },
    "onehot_encoder": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {"preprocessor_name": "onehot_encoder", "preprocessor_type": "encoder", "task": "preprocessing"},
    },
    "ordinal_encoder": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {"preprocessor_name": "ordinal_encoder", "preprocessor_type": "encoder", "task": "preprocessing"},
    },
    "label_binarizer": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {"preprocessor_name": "label_binarizer", "preprocessor_type": "encoder", "task": "preprocessing"},
    },
    "knn_imputer": {
        "node_type": "create_preprocessor",
        "category": "imputer",
        "task": "impute",
        "defaults": {"n_neighbors": 5},
        "metadata": {"preprocessor_name": "knn_imputer", "preprocessor_type": "imputer", "task": "preprocessing"},
    },
    "simple_imputer": {
        "node_type": "create_preprocessor",
        "category": "imputer",
        "task": "impute",
        "defaults": {"strategy": "mean"},
        "metadata": {"preprocessor_name": "simple_imputer", "preprocessor_type": "imputer", "task": "preprocessing"},
    },
    "binarizer": {
        "node_type": "create_preprocessor",
        "category": "binarizer",
        "task": "binarize",
        "defaults": {"threshold": 0.5},
        "metadata": {"preprocessor_name": "binarizer", "preprocessor_type": "binarizer", "task": "preprocessing"},
    },

    # ── NN Layers ──
    "input_layer": {
        "node_type": "create_input",
        "category": "layer",
        "task": "nn",
        "defaults": {"input_shape": [null]},
        "metadata": {},
    },
    "dense_layer": {
        "node_type": "dense",
        "category": "layer",
        "task": "nn",
        "defaults": {"units": 128, "activation": "relu"},
        "metadata": {},
    },
    "conv2d_layer": {
        "node_type": "conv2d",
        "category": "layer",
        "task": "nn",
        "defaults": {"filters": 32, "kernel_size": [3, 3], "strides": [1, 1], "padding": "valid", "activation": "relu"},
        "metadata": {},
    },
    "maxpool2d_layer": {
        "node_type": "maxpool2d",
        "category": "layer",
        "task": "nn",
        "defaults": {"pool_size": [2, 2], "strides": [2, 2], "padding": "valid"},
        "metadata": {},
    },
    "flatten_layer": {
        "node_type": "flatten",
        "category": "layer",
        "task": "nn",
        "defaults": {},
        "metadata": {},
    },
    "dropout_layer": {
        "node_type": "dropout",
        "category": "layer",
        "task": "nn",
        "defaults": {"rate": 0.5},
        "metadata": {},
    },
    "sequential_model": {
        "node_type": "sequential",
        "category": "nn_model",
        "task": "nn",
        "defaults": {},
        "metadata": {},
    },
    "model_compiler": {
        "node_type": "compile",
        "category": "compiler",
        "task": "compile",
        "defaults": {"optimizer": "adam", "loss": "categorical_crossentropy", "metrics": ["accuracy"]},
        "metadata": {},
    },
    "nn_fitter": {
        "node_type": "fit_net",
        "category": "fitter",
        "task": "fit_net",
        "defaults": {"batch_size": 32, "epochs": 10, "validation_split": 0.2},
        "metadata": {},
    },

    # ── Core Action Nodes ──
    "model_fitter": {
        "node_type": "fit_model",
        "category": "fitter",
        "task": "fit_model",
        "defaults": {},
        "metadata": {},
    },
    "predictor": {
        "node_type": "predict",
        "category": "predictor",
        "task": "predict",
        "defaults": {},
        "metadata": {},
    },
    "evaluator": {
        "node_type": "evaluate",
        "category": "evaluator",
        "task": "evaluate",
        "defaults": {},
        "metadata": {},
    },
    "preprocessor_fitter": {
        "node_type": "fit_preprocessor",
        "category": "fitter",
        "task": "fit_preprocessor",
        "defaults": {},
        "metadata": {},
    },
    "preprocessor_transformer": {
        "node_type": "transform",
        "category": "transformer",
        "task": "transform",
        "defaults": {},
        "metadata": {},
    },
    "fit_transform_preprocessor": {
        "node_type": "fit_transform",
        "category": "transformer",
        "task": "fit_transform",
        "defaults": {},
        "metadata": {},
    },
    "train_test_splitter": {
        "node_type": "train_test_split",
        "category": "splitter",
        "task": "split",
        "defaults": {"test_size": 0.3, "random_state": 42},
        "metadata": {},
    },

    # ── Data / I/O ──
    "data_loader": {
        "node_type": "data_loader",
        "category": "loader",
        "task": "load_data",
        "defaults": {},
        "metadata": {},
    },
    "node_loader": {
        "node_type": "load_template",
        "category": "loader",
        "task": "load_node",
        "defaults": {},
        "metadata": {},
    },
    "node_saver": {
        "node_type": "save_template",
        "category": "saver",
        "task": "save_node",
        "defaults": {},
        "metadata": {},
    },

    # ── Custom ──
    "splitter": {
        "node_type": "splitter",
        "category": "custom",
        "task": "split",
        "defaults": {},
        "metadata": {},
    },
    "joiner": {
        "node_type": "joiner",
        "category": "custom",
        "task": "join",
        "defaults": {},
        "metadata": {},
    },
    "node_template_saver": {
        "node_type": "save_template",
        "category": "saver",
        "task": "save",
        "defaults": {},
        "metadata": {},
    },
}


def resolve_node(node_name: str) -> dict | None:
    """Look up node metadata from registry. Returns None if unknown."""
    return NODE_REGISTRY.get(node_name)


VALID_NODE_NAMES = frozenset(NODE_REGISTRY.keys())
```

---

## Phase 2: Unified API Layer

### 2.1 New `NodeCreate` schema — `app/api/schemas/request/node.py`

Replace existing `NodeCreate`:

```python
class NodeCreate(BaseSchema):
    node_name: str = Field(..., max_length=255)
    params: dict[str, Any] | None = None           # hyperparameter overrides
    in_ports: dict[str, str] | None = None          # {"X": "dl_id:0:0", "y": "dl_id:0:1"}
    out_ports: dict[str, str] | None = None         # {"X_train": "fitter_id:0:0", ...}
    selected_output: str | None = None              # "Full", "X and y", etc.
    project_id: int | None = None
    workflow_id: int | None = None
    location_x: float = 0.0
    location_y: float = 0.0
    displayed_name: str | None = None
    message: str = "Done"
```

Keep `NodeUpdate` (updated to support `in_ports`/`out_ports` updates), `NodeSaveRequest`, `NodeLoadRequest`, `NodeTemplateSaveRequest`, `NodeTemplateLoadRequest`.

### 2.2 Rewrite `_helpers.py` — `app/api/v1/endpoints/_helpers.py`

```python
async def create_pending_node(request: Request, node_name: str, body: NodeCreate) -> dict:
    """Unified node creation with registry lookup, defaults merge, and validation."""
    from app.engine.configs.registry import resolve_node

    entry = resolve_node(node_name)
    if not entry:
        raise HTTPException(404, f"Unknown node: '{node_name}'")

    node_type = entry["node_type"]
    task = entry["task"]
    defaults = entry["defaults"]
    metadata = entry["metadata"]

    # Merge: defaults ← user params ← metadata
    params = {**defaults, **(body.params or {}), **metadata}
    if body.selected_output:
        params["selected_output"] = body.selected_output

    # Validate
    errors = validate_params(node_type, params)
    if errors:
        raise HTTPException(400, "; ".join(errors))

    # gui_meta (no children/parent)
    gui_meta = {
        "displayed_name": body.displayed_name or node_name,
        "location_x": body.location_x,
        "location_y": body.location_y,
        "message": body.message,
    }

    # Resolve component_id
    component_id = await _resolve_component_id(request, node_name)

    # Create node
    repo = NodeRepository(request.app.state.db_client)
    node = await repo.create(
        type=node_type, task=task, params=params,
        project_id=body.project_id, workflow_id=body.workflow_id,
        node_name=node_name, gui_meta=gui_meta,
        component_id=component_id,
        in_ports=body.in_ports or {},
        out_ports=body.out_ports or {},
        status="pending",
    )
    return _build_response(node, gui_meta)
```

### 2.3 Rewrite `nodes.py` — `app/api/v1/endpoints/nodes.py`

```python
nodes_router = APIRouter(prefix="/nodes", tags=["nodes"])

# ── CRUD ──
GET  /                    — list nodes
POST /                    — UNIFIED CREATE (registry lookup)
GET  /{node_pk}           — get node
PUT  /{node_pk}           — update node (supports in_ports/out_ports updates)
DELETE /{node_pk}         — delete node
DELETE /clear-all
DELETE /clear-project/
DELETE /clear-workflow/

# ── I/O (moved from io.py) ──
POST /save                — save node to disk
POST /load                — load node from disk
POST /save-template       — save as reusable template
POST /load-template       — load template
```

### 2.4 Delete old endpoint files

| File | Action |
|---|---|
| `api/v1/endpoints/models.py` | DELETE |
| `api/v1/endpoints/preprocessors.py` | DELETE |
| `api/v1/endpoints/nn.py` | DELETE |
| `api/v1/endpoints/data.py` | DELETE |
| `api/schemas/request/ml.py` | DELETE |
| `api/schemas/request/nn.py` | DELETE |
| `core/nodes_info.py` | DELETE (merged into registry.py) |

### 2.5 Update `router.py`

Remove: `models_router`, `preprocessors_router`, `nn_router`, `data_router`
Keep: `nodes_router`, `io_router` (export/import only), `components_router`, `projects_router`, `workflow_router`, `auth_router`, `health_router`

### 2.6 Update `request/__init__.py`

Remove all imports from `ml.py` and `nn.py`. Keep `NodeCreate`, `NodeUpdate`, I/O schemas.

### 2.7 Update `const_.py`

Replace hand-built lists with registry-derived:
```python
from .registry import NODE_REGISTRY, resolve_node

ALL_NODE_NAMES = list(NODE_REGISTRY.keys())
MODELS_NAMES = [n for n, e in NODE_REGISTRY.items() if e["node_type"] == "create_model"]
PREPROCESSORS_NAMES = [n for n, e in NODE_REGISTRY.items() if e["node_type"] == "create_preprocessor"]
# etc.
```

### 2.8 Update `NodeResponse` — `app/api/schemas/response/__init__.py`

Remove `children` and `parent` fields from `NodeResponse`.

---

## Phase 3: Engine Refactor (Port-Based Execution)

### 3A: Add `EnginePersistence.load_port()` — `engine/repositories/execution.py`

```python
@staticmethod
def load_port(port_ref: str, project_id: int = None):
    """Parse 'node_id:group_idx:port_idx' and load the specific output.

    For single-output nodes, returns the result as-is (no group/port extraction).
    For multi-output nodes, extracts result[group_idx:port_idx].
    """
    parts = port_ref.split(":")
    node_id = int(parts[0])
    group_idx = int(parts[1]) if len(parts) > 1 else None
    port_idx = int(parts[2]) if len(parts) > 2 else None

    success, result = EnginePersistence.load_node_data(
        node_id=node_id, project_id=project_id
    )
    if not success:
        return f"Failed to load port {port_ref}: {result}"

    if group_idx is not None and port_idx is not None:
        key = f"{group_idx}:{port_idx}"
        if isinstance(result, dict) and key in result:
            return result[key]
        # Single-output fallback
        return result

    return result
```

### 3B: Multi-output nodes store port-keyed results

**DataLoader** — currently creates 3 DB records (main + X child + y child). Change to 1 record:
```python
# Result stored as:
{"0:0": X_data, "0:1": y_data}  # for "X and y" output group
# OR
{"1:0": X_data}                  # for "X only" output group
```

**TrainTestSplit** — similar change:
```python
# "Full" output group:
{"0:0": X_train, "0:1": X_test, "0:2": y_train, "0:3": y_test}
# "Full (merged)":
{"1:0": train_data, "1:1": test_data}
```

**Splitter**:
```python
{"0:0": split_1, "0:1": split_2}
```

**FitTransform**:
```python
{"0:0": fitted_preprocessor, "0:1": transformed_data}
```

Single-output nodes (Model, Preprocessor, FitModel, Predict, Evaluate, etc.) keep single result. `load_port` handles the fallback.

### 3C: Update engine classes to use `in_ports` dict

Every engine class that reads `self._X_input`, `self._y_input`, `self.model`, `self.prev_node`, etc. from params — change to read from `self.in_ports` dict.

**Files to update and their port mappings:**

| File | Class | Current params | New in_ports keys |
|---|---|---|---|
| `engine/model/fit.py` | FitModel | `X`, `y`, `model` | `"X"`, `"y"`, `"model"` |
| `engine/model/predict.py` | Predict | `X`, `fitted_model` | `"X"`, `"fitted_model"` |
| `engine/model/evaluator.py` | Evaluate | `X`, `y`, `model` | `"X"`, `"y"`, `"model"` |
| `engine/preprocessing/fit.py` | FitPreprocessor | `data`, `preprocessor` | `"data"`, `"preprocessor"` |
| `engine/preprocessing/transform.py` | Transform | `data`, `fitted_preprocessor` | `"data"`, `"fitted_preprocessor"` |
| `engine/preprocessing/fit_transform.py` | FitTransform | `data`, `preprocessor` | `"data"`, `"preprocessor"` |
| `engine/nets/fit.py` | FitNet | `X`, `y`, `model` | `"X"`, `"y"`, `"model"` |
| `engine/nets/dnn_layers.py` | DenseLayer, Conv2DLayer, MaxPool2DLayer, FlattenLayer, DropoutLayer | `prev_node` | `"layer"` |
| `engine/nets/sequential.py` | SequentialNet | `layer` | `"layer"` |
| `engine/nets/compile.py` | CompileModel | `nn_model` | `"nn_model"` |
| `engine/other/custom.py` | Joiner | `data_1`, `data_2` | `"1"`, `"2"` (or `"3"`, `"4"`) |
| `engine/other/custom.py` | Splitter | `data` | `"data"` |
| `engine/other/dataLoader.py` | DataLoader | (no inputs, data from params) | (no change) |
| `engine/other/train_test_split.py` | TrainTestSplit | `X`, `y` | `"X"`, `"y"` |

**Example change for FitModel:**

Before:
```python
class FitModel(BaseNode):
    def __init__(self, X=None, y=None, model=None, model_path=None, **kwargs):
        self._X_input = X
        self._y_input = y
        self._model_input = model
        self._model_path = model_path
        super().__init__(**kwargs)

    def execute(self):
        self.X, self.y = EnginePersistence.load_data(self._X_input, self._y_input, project_id=self.project_id)
        # ...
```

After:
```python
class FitModel(BaseNode):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        model_ref = in_ports.get("model")
        X_ref = in_ports.get("X")
        y_ref = in_ports.get("y")

        self.model = EnginePersistence.load_port(model_ref, self.project_id)
        self.X = EnginePersistence.load_port(X_ref, self.project_id)
        self.y = EnginePersistence.load_port(y_ref, self.project_id)
        # ...
```

### 3D: Remove `children`/`parent` from BaseNode

- `engine/base_node.py`: Stop extracting `children` and `parent` from kwargs
- `gui_meta` no longer contains `children`/`parent`
- `_to_response()` in `nodes.py` stops reading them
- `NodeResponse` removes `children` and `parent` fields

### 3E: Update `base_node.py` to pass `in_ports`/`out_ports`

```python
class BaseNode:
    def __init__(self, **kwargs):
        # Extract metadata
        self.project_id = kwargs.pop("project_id", None)
        self.workflow_id = kwargs.pop("workflow_id", None)
        self.component_id = kwargs.pop("component_id", None)
        self.node_id = kwargs.pop("node_id", None)
        self.node_name = kwargs.pop("node_name", None)
        self.displayed_name = kwargs.pop("displayed_name", None)
        self.location_x = kwargs.pop("location_x", 0.0)
        self.location_y = kwargs.pop("location_y", 0.0)

        # Port-based connections (NEW)
        self.in_ports = kwargs.pop("in_ports", {}) or {}
        self.out_ports = kwargs.pop("out_ports", {}) or {}

        # Remaining → self.params
        self.params = kwargs
```

---

## Phase 4: Cleanup & Verification

### 4.1 Update `validation.py`
No structural changes needed — still validates by `node_type`. Port validation is implicit (client ensures port refs are correct from component definitions).

### 4.2 Update tests
- New test for unified `POST /nodes/` endpoint with registry lookup
- Tests for invalid node_name → 404
- Tests for defaults merge (user params override defaults)
- Tests for metadata injection (model_name/model_type/task)
- Tests for `EnginePersistence.load_port()` parsing
- Tests for port-keyed result storage
- Remove old per-type endpoint tests (if any exist beyond auth)
- Update existing engine tests to use `in_ports` instead of explicit params

### 4.3 Update `AGENTS.md`
Document:
- Unified endpoint (`POST /v1/nodes/` with `node_name`)
- Port-based connection system (`in_ports`/`out_ports` dicts)
- `NODE_REGISTRY` as single source of truth
- `EnginePersistence.load_port()` method
- Updated file structure
- Remove references to old per-type endpoints

### 4.4 Run verification
```sh
ruff check src/app/engine
ruff check src/app/api
pytest src/tests/ -v
```

---

## Files Changed Summary

| Action | File | Description |
|---|---|---|
| CREATE | `app/engine/configs/registry.py` | Unified node registry (NODE_REGISTRY + resolve_node) |
| REWRITE | `app/api/schemas/request/node.py` | New NodeCreate with in_ports/out_ports dicts, no children/parent |
| REWRITE | `app/api/v1/endpoints/_helpers.py` | Registry-aware create_pending_node |
| REWRITE | `app/api/v1/endpoints/nodes.py` | Unified CRUD + I/O routes |
| REWRITE | `app/engine/repositories/execution.py` | Add load_port() method |
| UPDATE | `app/api/v1/router.py` | Remove 4 old routers |
| UPDATE | `app/api/schemas/request/__init__.py` | Remove old schema imports |
| UPDATE | `app/api/schemas/response/__init__.py` | Remove children/parent from NodeResponse |
| UPDATE | `app/engine/configs/const_.py` | Derive lists from registry |
| UPDATE | `app/engine/base_node.py` | Add in_ports/out_ports, remove children/parent |
| UPDATE | `app/engine/model/fit.py` | Accept in_ports dict |
| UPDATE | `app/engine/model/predict.py` | Accept in_ports dict |
| UPDATE | `app/engine/model/evaluator.py` | Accept in_ports dict |
| UPDATE | `app/engine/preprocessing/fit.py` | Accept in_ports dict |
| UPDATE | `app/engine/preprocessing/transform.py` | Accept in_ports dict |
| UPDATE | `app/engine/preprocessing/fit_transform.py` | Accept in_ports dict |
| UPDATE | `app/engine/nets/fit.py` | Accept in_ports dict |
| UPDATE | `app/engine/nets/dnn_layers.py` | Accept in_ports dict |
| UPDATE | `app/engine/nets/sequential.py` | Accept in_ports dict |
| UPDATE | `app/engine/nets/compile.py` | Accept in_ports dict |
| UPDATE | `app/engine/other/custom.py` | Accept in_ports dict (Joiner, Splitter, TemplateSaver/Loader) |
| UPDATE | `app/engine/other/dataLoader.py` | Store port-keyed results instead of child records |
| UPDATE | `app/engine/other/train_test_split.py` | Store port-keyed results instead of child records |
| UPDATE | `src/tests/*` | New tests + update existing |
| UPDATE | `AGENTS.md` | Document new architecture |
| DELETE | `app/api/v1/endpoints/models.py` | |
| DELETE | `app/api/v1/endpoints/preprocessors.py` | |
| DELETE | `app/api/v1/endpoints/nn.py` | |
| DELETE | `app/api/v1/endpoints/data.py` | |
| DELETE | `app/api/schemas/request/ml.py` | |
| DELETE | `app/api/schemas/request/nn.py` | |
| DELETE | `app/core/nodes_info.py` | Merged into registry.py |

---

## Key Pitfalls to Watch For

1. **`defaults.py` still needed at execution time** — it has the sklearn class references (`Ridge`, `SVR`, etc.) that engine classes import. Don't delete it; just stop using it as a standalone config. The registry handles the lookup, but the class references in `defaults.py` (or `models.py`/`preprocessors.py`) are still needed for `Model.__init__` → `self.node_class` property.

2. **`engine/configs/models.py` and `engine/configs/preprocessors.py`** — These are the NESTED dicts (type→task→name→{node,params}) used by `Model._get_default_params()` and `Model.node_class`. Since we're adding `metadata` to the registry that includes `model_type`/`task`, the Model class can now look up defaults from the flat registry instead of the nested dict. BUT the `node_class` property still needs the sklearn class reference. Options:
   - Add `"class": Ridge` to the registry entry (avoids importing models.py at all)
   - OR keep `models.py`/`preprocessors.py` for the class lookup

3. **`action_mixin.py`** — `_resolve_resource()` currently accepts `int | dict | str` for resource refs. With ports, it should also accept port ref strings like `"123:0:0"`. May need to parse port refs in `_resolve_resource`.

4. **`WorkflowExecutor` / Celery task** — injects `project_id` and `workflow_id` into node data before execution. The new engine classes receive `in_ports`/`out_ports` from the node's stored data. Make sure the Celery task passes these through.

5. **`component_id` resolution** — Currently `ComponentRepository.get_by_name(node_name)` matches the component in the DB. This still works with the unified endpoint since we pass `node_name`.

6. **`load_handler` in BaseNode** — Currently calls `build_payload()` then `EnginePersistence.save_result()`. For multi-output nodes, `save_result()` needs to handle port-keyed dicts. The `save_result` method should detect dict payloads with `"0:0"` keys and store them as structured results.

7. **Backward compatibility for import-project** — Old project imports have nodes with `children`/`parent` in gui_meta. The import endpoint (`io.py`) should handle both old and new formats.
