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
