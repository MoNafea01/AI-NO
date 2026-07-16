"""Parameter validation for all node types.

Each ``validate_*`` function takes the full node data dict and returns a list
of error messages. An empty list means the parameters are valid.
"""

from app.engine.configs.registry import NODE_REGISTRY

__all__ = ["VALIDATION_REGISTRY", "validate_params"]


def _validate_model(data: dict) -> list[str]:
    errors = []
    model_type = data.get("model_type", "")
    task = data.get("task", "")
    model_name = data.get("model_name", "")

    valid = False
    for entry in NODE_REGISTRY.values():
        if entry["node_type"] == "create_model":
            meta = entry.get("metadata", {})
            if (
                meta.get("model_name") == model_name
                and meta.get("model_type") == model_type
                and meta.get("task") == task
            ):
                valid = True
                break

    if not valid:
        # Check individually for better error messages
        names = [
            e.get("metadata", {}).get("model_name")
            for e in NODE_REGISTRY.values()
            if e["node_type"] == "create_model"
        ]
        types = set(
            e.get("metadata", {}).get("model_type")
            for e in NODE_REGISTRY.values()
            if e["node_type"] == "create_model"
        )
        tasks = set(
            e.get("metadata", {}).get("task")
            for e in NODE_REGISTRY.values()
            if e["node_type"] == "create_model"
        )

        if model_type not in types:
            errors.append(f"Unknown model_type: '{model_type}'")
        if task not in tasks:
            errors.append(f"Unknown task '{task}'")
        if model_name not in names:
            errors.append(f"Unknown model_name '{model_name}'")

    return errors


def _validate_preprocessor(data: dict) -> list[str]:
    errors = []
    pptype = data.get("preprocessor_type", "")
    ppname = data.get("preprocessor_name", "")
    pptask = data.get("task", "")

    valid = False
    for entry in NODE_REGISTRY.values():
        if entry["node_type"] == "create_preprocessor":
            meta = entry.get("metadata", {})
            if (
                meta.get("preprocessor_name") == ppname
                and meta.get("preprocessor_type") == pptype
                and meta.get("task") == pptask
            ):
                valid = True
                break

    if not valid:
        names = [
            e.get("metadata", {}).get("preprocessor_name")
            for e in NODE_REGISTRY.values()
            if e["node_type"] == "create_preprocessor"
        ]
        types = set(
            e.get("metadata", {}).get("preprocessor_type")
            for e in NODE_REGISTRY.values()
            if e["node_type"] == "create_preprocessor"
        )
        tasks = set(
            e.get("metadata", {}).get("task")
            for e in NODE_REGISTRY.values()
            if e["node_type"] == "create_preprocessor"
        )

        if pptype not in types:
            errors.append(f"Unknown preprocessor_type: '{pptype}'")
        if pptask not in tasks:
            errors.append(f"Unknown task '{pptask}'")
        if ppname not in names:
            errors.append(f"Unknown preprocessor_name '{ppname}'")

    return errors


def _validate_data_loader(data: dict) -> list[str]:
    errors = []
    if not data.get("dataset_name") and not data.get("dataset_path"):
        errors.append("data_loader requires 'dataset_name' or 'dataset_path' in params")
    return errors


def _validate_train_test_split(data: dict) -> list[str]:
    return []


def _validate_splitter(data: dict) -> list[str]:
    return []


def _validate_joiner(data: dict) -> list[str]:
    return []


def _validate_fit_model(data: dict) -> list[str]:
    return []


def _validate_predict(data: dict) -> list[str]:
    return []


def _validate_evaluate(data: dict) -> list[str]:
    return []


def _validate_fit_preprocessor(data: dict) -> list[str]:
    return []


def _validate_transform(data: dict) -> list[str]:
    return []


def _validate_fit_transform(data: dict) -> list[str]:
    return []


def _validate_input_layer(data: dict) -> list[str]:
    return []


def _validate_dense(data: dict) -> list[str]:
    return []


def _validate_conv2d(data: dict) -> list[str]:
    return []


def _validate_maxpool2d(data: dict) -> list[str]:
    return []


def _validate_flatten(data: dict) -> list[str]:
    return []


def _validate_dropout(data: dict) -> list[str]:
    return []


def _validate_sequential(data: dict) -> list[str]:
    return []


def _validate_compile(data: dict) -> list[str]:
    return []


def _validate_fit_net(data: dict) -> list[str]:
    return []


def _validate_save_template(data: dict) -> list[str]:
    return []


def _validate_load_template(data: dict) -> list[str]:
    return []


VALIDATION_REGISTRY: dict[str, callable] = {
    "data_loader": _validate_data_loader,
    "train_test_split": _validate_train_test_split,
    "joiner": _validate_joiner,
    "splitter": _validate_splitter,
    "create_model": _validate_model,
    "fit_model": _validate_fit_model,
    "predict": _validate_predict,
    "evaluate": _validate_evaluate,
    "create_preprocessor": _validate_preprocessor,
    "fit_preprocessor": _validate_fit_preprocessor,
    "transform": _validate_transform,
    "fit_transform": _validate_fit_transform,
    "create_input": _validate_input_layer,
    "dense": _validate_dense,
    "conv2d": _validate_conv2d,
    "maxpool2d": _validate_maxpool2d,
    "flatten": _validate_flatten,
    "dropout": _validate_dropout,
    "sequential": _validate_sequential,
    "compile": _validate_compile,
    "fit_net": _validate_fit_net,
    "save_template": _validate_save_template,
    "load_template": _validate_load_template,
}


def validate_params(node_type: str, data: dict) -> list[str]:
    """Validate node params for *node_type*.

    Returns a list of error messages (empty = valid).
    """
    validator = VALIDATION_REGISTRY.get(node_type)
    if not validator:
        return [f"No validator registered for node_type '{node_type}'"]
    return validator(data)
