from __init__ import *

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
 'dropout_layer', 'sequential_model', 'nn_model_fitter','model_compiler', 
 ]

api_ref = [
    *models, "fit_model/", "predict/", "evaluate/",
    *preprocessors, "fit_preprocessor/", "transform/", "fit_transform/",
    "data_loader/", "splitter/", "joiner/", "train_test_split/", 
    "create_input/", "conv2d/", "maxpool2d/", "flatten/", "dense/", "dropout/", "sequential/", "fit_net/", "compile/"
]
mapper = dict(zip(nodes, api_ref))
