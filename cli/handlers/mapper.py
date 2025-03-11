
names = [
    'model', "model_fitter", "predictor", "evaluator",
    "preprocessor", "preprocessor_fitter", "transformer", "fit_transformer",
    "data_loader", "splitter", "joiner", "train_test_split", "node_saver", "node_loader", 
    "input_layer", "conv2d", "maxpool2d", "flatten", "dense", "dropout", "sequential"
]
api_ref = [
    "create_model/", "fit_model/", "predict/", "evaluate/",
    "create_preprocessor/", "fit_preprocessor/", "transform/", "fit_transform/",
    "data_loader/", "splitter/", "joiner/", "train_test_split/", "save_node/", "load_node/",
    "create_input/", "conv2d/", "maxpool2d/", "flatten/", "dense/", "dropout/", "sequential/"
]
mapper = dict(zip(names, api_ref))
