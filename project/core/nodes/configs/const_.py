import os

DICT_NODES = ['data', 'data_1', 'data_2', 
              'X', 'y', 'model', 'y_true', 
              'y_pred', 'preprocessor', 'prev_node', 
              'layer', 'node']

PARENT_NODES = ["dense_layer", "flatten_layer", "dropout_layer", "maxpool2d_layer", "conv2d_layer"]

MULTI_CHANNEL_NODES = ["data_loader", "train_test_split", "splitter", "fitter_transformer"]
MODELS_TASKS = ["regression", "classification", "fit_model", "predict", "evaluate"]
PREPROCESSORS_TASKS = ["preprocessing", "fit_preprocessor", "transform", "fit_transform"]
LAYERS = ["neural_network"]
DATA_NODES = ["load_data", "split", "join"]

if os.getenv("TESTING_ENV", "0") == "1":
    SAVING_DIR = r"core\test_saved"
else:
    SAVING_DIR = r"core\saved"
