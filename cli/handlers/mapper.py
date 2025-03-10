
names = [
    'linear_regression', 'ridge', 'lasso', 'elastic_net', 'sgd_regression',
    "logistic_regression", "ridge_classifier", "sgd_classifier",
    "rbf_svr", "linear_svr", "poly_svr", "sigmoid_svr",
    "linear_svc", "rbf_svc", "poly_svc", "sigmoid_svc",
    "dtr", "dtc", "rfr", "rfc", "gbr", "gbc", "adr", "adc",
    "br", "bc", "gaussian_nb", "multinomial_nb", "bernoulli_nb","knnr", "knnc",

    "standard_scaler", "minmax_scaler", "maxabs_scaler", "robust_scaler",
    "normalizer", "label_encoder", "onehot_encoder", "ordinal_encoder",
    "label_binarizer", "simple_imputer", "knn_imputer", "binarizer",

    "model_fitter", "predictor", "preprocessor_fitter", "data_transformer",
    "fit_transformer", "splitter", "data_loader", "node_saver", "node_loader", 
    "joiner", "evaluator", "train_test_split",
    "input_layer", "conv2d_layer", "maxpool2d_layer", "flatten_layer", "dense_layer", 
    "dropout_layer", "sequential_model"
]
api_ref = [
    "create_model/", "create_model/", "create_model/", "create_model/", "create_model/",
    "create_model/", "create_model/", "create_model/", "create_model/", "create_model/",
    "create_model/", "create_model/", "create_model/", "create_model/", "create_model/",
    "create_model/", "create_model/", "create_model/", "create_model/", "create_model/",
    "create_model/", "create_model/", "create_model/", "create_model/", "create_model/",
    "create_model/", "create_model/", "create_model/", "create_model/", "create_model/", 
    "create_model/", 
    "create_preprocessor/", "create_preprocessor/", "create_preprocessor/", "create_preprocessor/", 
    "create_preprocessor/", "create_preprocessor/", "create_preprocessor/", "create_preprocessor/", 
    "create_preprocessor/", "create_preprocessor/", "create_preprocessor/", "create_preprocessor/", 

    "fit_model/", "predict/", "fit_preprocessor/", "transform/", 
    "fit_transform/", "splitter/", "data_loader/", "save_node/", "load_node/",
    "joiner/", "evaluate/", "train_test_split/", 
    "create_input/", "conv2d/", "maxpool2d/", "flatten/", "dense/", "dropout/", "sequential/"
]
mapper = dict(zip(names, api_ref))
