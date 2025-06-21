from core.nodes.configs.models import MODELS
from core.nodes.configs.preprocessors import PREPROCESSORS
from django.conf import settings
import os
import pandas as pd
base_dir = settings.BASE_DIR if hasattr(settings, 'BASE_DIR') else os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../../'))
schema_dir = os.path.join(base_dir, 'core', 'schema.xlsx')

# these nodes are in json format and are used to be input to other nodes
DICT_NODES = ['data', 'data_1', 'data_2', 'X', 
              'y', 'model', 'y_true', 'y_pred', 
              'preprocessor', 'prev_node', 'layer', 'node', 
              'compiled_model', 'nn_model', 'fitted_model', 'fitted_preprocessor']

# these are layers names
PARENT_NODES = ["dense_layer", "flatten_layer", "dropout_layer", "maxpool2d_layer", "conv2d_layer", "sequential_model"]

# nodes with more than one record on database
MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer"]

CHILDREN_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer", 
                  "dense_layer", "flatten_layer", "dropout_layer", "maxpool2d_layer", "conv2d_layer"]

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
 'dropout_layer', 'sequential_model', 'nn_fitter','model_compiler',  'node_saver', 'node_loader',
 'node_template_saver', 'template'
 ]

api_ref = [
    *models, "fit_model/", "predict/", "evaluate/",
    *preprocessors, "fit_preprocessor/", "transform/", "fit_transform/",
    "data_loader/", "splitter/", "joiner/", "train_test_split/", 
    "create_input/", "conv2d/", "maxpool2d/", "flatten/", "dense/", "dropout/", "sequential/", 
    "fit_net/", "compile/", "save_node/", "load_node/",
    'save_template/', 'template/'
]
mapper = dict(zip(nodes, api_ref))

def get_node_name_by_api_ref(ref, request):
    """
    Get the node name by api ref.
    """
    query_params = request.query_params.copy()

    template_id = query_params.pop('template_id', None) 
    if isinstance(template_id, list):
        template_id = template_id[0] if template_id else None
    
    try:
        node_name = None
        schema = pd.read_excel(schema_dir, sheet_name="Sheet1")
        if ref == 'create_model/':
            node_name = request.data.get('model_name')
        elif ref == 'create_preprocessor/':
            node_name = request.data.get('preprocessor_name')
        else:
            node = schema[schema['api_call'] == ref].iloc[0]
            node_name = node['node_name']
    
        return node_name

    
    except Exception as e:
        print(f"Error: {e}")
        return None

if settings.TESTING:
    SAVING_DIR = "core/test_saved"
else:
    SAVING_DIR = "core/saved"

