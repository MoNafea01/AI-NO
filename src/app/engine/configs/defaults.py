from sklearn.datasets import (
    load_diabetes,
    load_digits,
    load_iris,
    make_classification,
    make_regression,
)
from sklearn.ensemble import (
    AdaBoostClassifier,
    AdaBoostRegressor,
    BaggingClassifier,
    BaggingRegressor,
    GradientBoostingClassifier,
    GradientBoostingRegressor,
    RandomForestClassifier,
    RandomForestRegressor,
)
from sklearn.impute import KNNImputer, SimpleImputer
from sklearn.linear_model import (
    ElasticNet,
    Lasso,
    LinearRegression,
    LogisticRegression,
    Ridge,
    RidgeClassifier,
    SGDClassifier,
    SGDRegressor,
)
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    log_loss,
    mean_absolute_error,
    mean_squared_error,
    precision_score,
    r2_score,
    recall_score,
    root_mean_squared_error,
)
from sklearn.naive_bayes import (
    BernoulliNB,
    GaussianNB,
    MultinomialNB,
)
from sklearn.neighbors import (
    KNeighborsClassifier,
    KNeighborsRegressor,
)
from sklearn.preprocessing import (
    Binarizer,
    LabelBinarizer,
    LabelEncoder,
    MaxAbsScaler,
    MinMaxScaler,
    Normalizer,
    OneHotEncoder,
    OrdinalEncoder,
    RobustScaler,
    StandardScaler,
)
from sklearn.svm import (
    SVC,
    SVR,
)
from sklearn.tree import (
    DecisionTreeClassifier,
    DecisionTreeRegressor,
)

MODELS = {
    "ridge": {
        "node": Ridge,
        "params": {
            "alpha": 1.0,
        },
    },
    "lasso": {
        "node": Lasso,
        "params": {
            "alpha": 1.0,
        },
    },
    "elastic_net": {
        "node": ElasticNet,
        "params": {
            "alpha": 1.0,
            "l1_ratio": 0.5,
        },
    },
    "linear_regression": {"node": LinearRegression, "params": {}},
    "sgd_regression": {
        "node": SGDRegressor,
        "params": {
            "penalty": "l2",
        },
    },
    "svr": {
        "node": SVR,
        "params": {
            "C": 1.0,
            "kernel": "rbf",
        },
    },
    "decision_tree_regressor": {
        "node": DecisionTreeRegressor,
        "params": {
            "max_depth": None,
        },
    },
    "random_forest_regressor": {
        "node": RandomForestRegressor,
        "params": {
            "n_estimators": 100,
            "max_depth": None,
        },
    },
    "gradient_boosting_regressor": {"node": GradientBoostingRegressor, "params": {}},
    "adaboost_regressor": {"node": AdaBoostRegressor, "params": {}},
    "bagging_regressor": {"node": BaggingRegressor, "params": {}},
    "knn_regressor": {
        "node": KNeighborsRegressor,
        "params": {
            "n_neighbors": 5,
        },
    },
    "gaussian_nb": {"node": GaussianNB, "params": {}},
    "bernoulli_nb": {"node": BernoulliNB, "params": {}},
    "multinomial_nb": {"node": MultinomialNB, "params": {}},
    "sgd_classifier": {
        "node": SGDClassifier,
        "params": {
            "penalty": "l2",
        },
    },
    "ridge_classifier": {
        "node": RidgeClassifier,
        "params": {
            "alpha": 1.0,
        },
    },
    "logistic_regression": {
        "node": LogisticRegression,
        "params": {
            "penalty": "l2",
            "C": 1.0,
        },
    },
    "svc": {
        "node": SVC,
        "params": {
            "C": 1.0,
            "kernel": "rbf",
        },
    },
    "decision_tree_classifier": {
        "node": DecisionTreeClassifier,
        "params": {
            "max_depth": None,
        },
    },
    "random_forest_classifier": {
        "node": RandomForestClassifier,
        "params": {
            "n_estimators": 100,
            "max_depth": None,
        },
    },
    "gradient_boosting_classifier": {"node": GradientBoostingClassifier, "params": {}},
    "adaboost_classifier": {"node": AdaBoostClassifier, "params": {}},
    "bagging_classifier": {"node": BaggingClassifier, "params": {}},
    "knn_classifier": {
        "node": KNeighborsClassifier,
        "params": {
            "n_neighbors": 5,
        },
    },
}

PREPROCESSORS = {
    "maxabs_scaler": {"node": MaxAbsScaler, "params": {}},
    "normalizer": {"node": Normalizer, "params": {"norm": "l2"}},
    "minmax_scaler": {"node": MinMaxScaler, "params": {"feature_range": (0, 1)}},
    "robust_scaler": {"node": RobustScaler, "params": {"quantile_range": (25.0, 75.0)}},
    "standard_scaler": {"node": StandardScaler, "params": {"with_mean": True, "with_std": True}},
    "label_encoder": {"node": LabelEncoder, "params": {}},
    "onehot_encoder": {"node": OneHotEncoder, "params": {}},
    "ordinal_encoder": {"node": OrdinalEncoder, "params": {}},
    "label_binarizer": {"node": LabelBinarizer, "params": {}},
    "knn_imputer": {"node": KNNImputer, "params": {"n_neighbors": 5}},
    "simple_imputer": {"node": SimpleImputer, "params": {"strategy": "mean"}},
    "binarizer": {"node": Binarizer, "params": {"threshold": 0.5}},
}

NETS = {
    "input_layer": {"node": "InputLayer", "params": {"input_shape": (None,)}},
    "conv2d_layer": {
        "node": "Conv2D",
        "params": {
            "filters": 32,
            "kernel_size": (3, 3),
            "strides": (1, 1),
            "padding": "valid",
            "activation": "relu",
        },
    },
    "maxpool2d_layer": {
        "node": "MaxPooling2D",
        "params": {"pool_size": (2, 2), "strides": (2, 2), "padding": "valid"},
    },
    "flatten_layer": {"node": "Flatten", "params": {}},
    "dense_layer": {"node": "Dense", "params": {"units": 128, "activation": "relu"}},
    "dropout_layer": {"node": "Dropout", "params": {"rate": 0.5}},
    "sequential_model": {"node": "Sequential", "params": {}},
    "model_compiler": {
        "node": "compile",
        "params": {
            "optimizer": "adam",
            "loss": "categorical_crossentropy",
            "metrics": ["accuracy"],
        },
    },
    "nn_fitter": {
        "node": "fit",
        "params": {"batch_size": 32, "epochs": 10, "validation_split": 0.2},
    },
}

DATASETS = {
    "iris": load_iris,
    "digits": load_digits,
    "diabetes": load_diabetes,
    "make_regression": make_regression,
    "make_classification": make_classification,
}


METRICS = {
    "f1": f1_score,
    "r2": r2_score,
    "recall": recall_score,
    "mse": mean_squared_error,
    "accuracy": accuracy_score,
    "mae": mean_absolute_error,
    "precision": precision_score,
    "log_loss": log_loss,
    "rmse": root_mean_squared_error,
}
