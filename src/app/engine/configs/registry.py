"""Unified node registry — single source of truth for node_name → dispatch + defaults + metadata.

Replaces ``core/nodes_info.py`` and the scattered name→type lookups.
"""

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
        "metadata": {
            "model_name": "elastic_net",
            "model_type": "linear_models",
            "task": "regression",
        },
    },
    "linear_regression": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {},
        "metadata": {
            "model_name": "linear_regression",
            "model_type": "linear_models",
            "task": "regression",
        },
    },
    "sgd_regression": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "regression",
        "defaults": {"penalty": "l2"},
        "metadata": {
            "model_name": "sgd_regression",
            "model_type": "linear_models",
            "task": "regression",
        },
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
        "metadata": {
            "model_name": "decision_tree_regressor",
            "model_type": "tree",
            "task": "regression",
        },
    },
    "random_forest_regressor": {
        "node_type": "create_model",
        "category": "tree",
        "task": "regression",
        "defaults": {"n_estimators": 100, "max_depth": None},
        "metadata": {
            "model_name": "random_forest_regressor",
            "model_type": "tree",
            "task": "regression",
        },
    },
    "gradient_boosting_regressor": {
        "node_type": "create_model",
        "category": "tree",
        "task": "regression",
        "defaults": {},
        "metadata": {
            "model_name": "gradient_boosting_regressor",
            "model_type": "tree",
            "task": "regression",
        },
    },
    "adaboost_regressor": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "regression",
        "defaults": {},
        "metadata": {
            "model_name": "adaboost_regressor",
            "model_type": "ensemble",
            "task": "regression",
        },
    },
    "bagging_regressor": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "regression",
        "defaults": {},
        "metadata": {
            "model_name": "bagging_regressor",
            "model_type": "ensemble",
            "task": "regression",
        },
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
        "metadata": {
            "model_name": "gaussian_nb",
            "model_type": "naive_bayes",
            "task": "classification",
        },
    },
    "bernoulli_nb": {
        "node_type": "create_model",
        "category": "naive_bayes",
        "task": "classification",
        "defaults": {},
        "metadata": {
            "model_name": "bernoulli_nb",
            "model_type": "naive_bayes",
            "task": "classification",
        },
    },
    "multinomial_nb": {
        "node_type": "create_model",
        "category": "naive_bayes",
        "task": "classification",
        "defaults": {},
        "metadata": {
            "model_name": "multinomial_nb",
            "model_type": "naive_bayes",
            "task": "classification",
        },
    },
    "sgd_classifier": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "classification",
        "defaults": {"penalty": "l2"},
        "metadata": {
            "model_name": "sgd_classifier",
            "model_type": "linear_models",
            "task": "classification",
        },
    },
    "ridge_classifier": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "classification",
        "defaults": {"alpha": 1.0},
        "metadata": {
            "model_name": "ridge_classifier",
            "model_type": "linear_models",
            "task": "classification",
        },
    },
    "logistic_regression": {
        "node_type": "create_model",
        "category": "linear_models",
        "task": "classification",
        "defaults": {"penalty": "l2", "C": 1.0},
        "metadata": {
            "model_name": "logistic_regression",
            "model_type": "linear_models",
            "task": "classification",
        },
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
        "metadata": {
            "model_name": "decision_tree_classifier",
            "model_type": "tree",
            "task": "classification",
        },
    },
    "random_forest_classifier": {
        "node_type": "create_model",
        "category": "tree",
        "task": "classification",
        "defaults": {"n_estimators": 100, "max_depth": None},
        "metadata": {
            "model_name": "random_forest_classifier",
            "model_type": "tree",
            "task": "classification",
        },
    },
    "gradient_boosting_classifier": {
        "node_type": "create_model",
        "category": "tree",
        "task": "classification",
        "defaults": {},
        "metadata": {
            "model_name": "gradient_boosting_classifier",
            "model_type": "tree",
            "task": "classification",
        },
    },
    "adaboost_classifier": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "classification",
        "defaults": {},
        "metadata": {
            "model_name": "adaboost_classifier",
            "model_type": "ensemble",
            "task": "classification",
        },
    },
    "bagging_classifier": {
        "node_type": "create_model",
        "category": "ensemble",
        "task": "classification",
        "defaults": {},
        "metadata": {
            "model_name": "bagging_classifier",
            "model_type": "ensemble",
            "task": "classification",
        },
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
        "metadata": {
            "preprocessor_name": "standard_scaler",
            "preprocessor_type": "scaler",
            "task": "preprocessing",
        },
    },
    "maxabs_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {},
        "metadata": {
            "preprocessor_name": "maxabs_scaler",
            "preprocessor_type": "scaler",
            "task": "preprocessing",
        },
    },
    "normalizer": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"norm": "l2"},
        "metadata": {
            "preprocessor_name": "normalizer",
            "preprocessor_type": "scaler",
            "task": "preprocessing",
        },
    },
    "minmax_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"feature_range": [0, 1]},
        "metadata": {
            "preprocessor_name": "minmax_scaler",
            "preprocessor_type": "scaler",
            "task": "preprocessing",
        },
    },
    "robust_scaler": {
        "node_type": "create_preprocessor",
        "category": "scaler",
        "task": "scale",
        "defaults": {"quantile_range": [25.0, 75.0]},
        "metadata": {
            "preprocessor_name": "robust_scaler",
            "preprocessor_type": "scaler",
            "task": "preprocessing",
        },
    },
    "label_encoder": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {
            "preprocessor_name": "label_encoder",
            "preprocessor_type": "encoder",
            "task": "preprocessing",
        },
    },
    "onehot_encoder": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {
            "preprocessor_name": "onehot_encoder",
            "preprocessor_type": "encoder",
            "task": "preprocessing",
        },
    },
    "ordinal_encoder": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {
            "preprocessor_name": "ordinal_encoder",
            "preprocessor_type": "encoder",
            "task": "preprocessing",
        },
    },
    "label_binarizer": {
        "node_type": "create_preprocessor",
        "category": "encoder",
        "task": "encode",
        "defaults": {},
        "metadata": {
            "preprocessor_name": "label_binarizer",
            "preprocessor_type": "encoder",
            "task": "preprocessing",
        },
    },
    "knn_imputer": {
        "node_type": "create_preprocessor",
        "category": "imputer",
        "task": "impute",
        "defaults": {"n_neighbors": 5},
        "metadata": {
            "preprocessor_name": "knn_imputer",
            "preprocessor_type": "imputer",
            "task": "preprocessing",
        },
    },
    "simple_imputer": {
        "node_type": "create_preprocessor",
        "category": "imputer",
        "task": "impute",
        "defaults": {"strategy": "mean"},
        "metadata": {
            "preprocessor_name": "simple_imputer",
            "preprocessor_type": "imputer",
            "task": "preprocessing",
        },
    },
    "binarizer": {
        "node_type": "create_preprocessor",
        "category": "binarizer",
        "task": "binarize",
        "defaults": {"threshold": 0.5},
        "metadata": {
            "preprocessor_name": "binarizer",
            "preprocessor_type": "binarizer",
            "task": "preprocessing",
        },
    },
    # ── NN Layers ──
    "input_layer": {
        "node_type": "create_input",
        "category": "layer",
        "task": "nn",
        "defaults": {"input_shape": [None]},
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
        "defaults": {
            "filters": 32,
            "kernel_size": [3, 3],
            "strides": [1, 1],
            "padding": "valid",
            "activation": "relu",
        },
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
        "defaults": {
            "optimizer": "adam",
            "loss": "categorical_crossentropy",
            "metrics": ["accuracy"],
        },
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
