import os
from core.nodes.configs.models import MODELS
from core.nodes.configs.preprocessors import PREPROCESSORS

# these nodes are in json format and are used to be input to other nodes
DICT_NODES = ['data', 'data_1', 'data_2', 
              'X', 'y', 'model', 'y_true', 
              'y_pred', 'preprocessor', 'prev_node', 
              'layer', 'node']

# these are layers names
PARENT_NODES = ["dense_layer", "flatten_layer", "dropout_layer", "maxpool2d_layer", "conv2d_layer"]

# nodes with more than one record on database
MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer"]


MODELS_NAMES = ["model_fitter", "evaluator", "predictor"]
for model_type in MODELS.keys():
    for model_task in MODELS[model_type].keys():
        models_names = MODELS[model_type][model_task].keys()
        MODELS_NAMES.extend(models_names)

MODELS_TASKS = ["regression", "classification", "fit_model", "predict", "evaluate"]


PREPROCESSORS_NAMES = ["fitter_transformer", "preprocessor_fitter", "transformer"]
for preprocessor_type in PREPROCESSORS.keys():
    preprocessors_names = PREPROCESSORS[preprocessor_type].keys()
    PREPROCESSORS_NAMES.extend(preprocessors_names)
PREPROCESSORS_TASKS = ["preprocessing", "fit_preprocessor", "transform", "fit_transform"]


NN_NAMES = ["input_layer", "sequential_model", "dense_layer", "flatten_layer", "dropout_layer", "maxpool2d_layer", "conv2d_layer",
            "model_compiler", "nn_fitter"]
NN_TASKS = ["neural_network"]

DATA_HANDLER_NAMES = ["data_loader", "train_test_split", "splitter", "joiner"]
DATA_HANDLER_TASKS = ["load_data", "split", "join"]

DATA_NODES = ["data_loader", "train_test_split", "splitter", "joiner",
              "predictor", "evaluator", "transformer"]

if os.getenv("TESTING_ENV", "0") == "1":
    SAVING_DIR = r"core\test_saved"
else:
    SAVING_DIR = r"core\saved"


models = ["create_model/"] * 31
preprocessors = ["create_preprocessor/"] * 12

nodes = ['ridge', 'lasso', 'linear_regression', 'sgd_regression', 'elastic_net', 'sgd_classifier', 
 'ridge_classifier', 'logistic_regression', 'rbf_svr', 'linear_svr', 'poly_svr', 'sigmoid_svr', 
 'rbf_svc', 'linear_svc', 'poly_svc', 'sigmoid_svc', 'bagging_regressor', 'adaboost_regressor', 
 'gradient_boosting_regressor', 'decision_tree_regressor', 'random_forest_regressor', 'bagging_classifier', 
 'adaboost_classifier', 'gradient_boosting_classifier', 'decision_tree_classifier', 'random_forest_classifier', 
 'gaussian_nb', 'bernoulli_nb', 'multinomial_nb', 'knn_regressor', 'knn_classifier',

 'model_fitter', 'predictor', 'evaluator', 

 'maxabs_scaler', 'normalizer', 'minmax_scaler', 'robust_scaler', 
 'standard_scaler', 'label_encoder', 'onehot_encoder', 'ordinal_encoder', 
 'label_binarizer', 'knn_imputer', 'simple_imputer', 'binarizer',

 'preprocessor_fitter', 'transformer', 'fitter_transformer', 

 "data_loader", "splitter", "joiner", "train_test_split",

 'input_layer', 'conv2d_layer', 'maxpool2d_layer', 'flatten_layer', 'dense_layer', 
 'dropout_layer', 'sequential_model', 'nn_fitter','model_compiler',  'node_saver', 'node_loader'
 ]

api_ref = [
    *models, "fit_model/", "predict/", "evaluate/",
    *preprocessors, "fit_preprocessor/", "transform/", "fit_transform/",
    "data_loader/", "splitter/", "joiner/", "train_test_split/", 
    "create_input/", "conv2d/", "maxpool2d/", "flatten/", "dense/", "dropout/", "sequential/", 
    "fit_net/", "compile/", "save_node/", "load_node/"
]
mapper = dict(zip(nodes, api_ref))

def get_node_name_by_api_ref(api_ref, request):
    """
    Get the node name by api ref.
    """
    for name, api in mapper.items():
        if api == api_ref:
            if name in MODELS_NAMES[3:]:
                node_name = request.data.get("model_name")
            elif name in PREPROCESSORS_NAMES[3:]:
                node_name = request.data.get("preprocessor_name")
            else:
                node_name = name
            return node_name
    return None