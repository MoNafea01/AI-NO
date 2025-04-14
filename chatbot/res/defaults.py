import json


nodes = [ 'ridge', 'lasso', 'linear_regression', 'sgd_regression', 'elastic_net', 'sgd_classifier', 
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
names = [
    'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 
    'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 
    'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 'model', 
    'model', 
    "model_fitter", "predictor", "evaluator",
    "preprocessor", "preprocessor", "preprocessor", "preprocessor", "preprocessor", "preprocessor", 
    "preprocessor", "preprocessor", "preprocessor", "preprocessor", "preprocessor", "preprocessor", 
    "preprocessor_fitter", "transformer", "fit_transformer",
    "data_loader", "splitter", "joiner", "train_test_split",
    "input_layer", "conv2d", "maxpool2d", "flatten", "dense", "dropout", "sequential", "fit_net", "compile_net"
]

mapp = dict(zip(nodes, names))
json.dumps(mapp, indent=4)
with open('mapping.json', 'w') as f:
    json.dump(mapp, f, indent=4)

####################################################################################################

####################################################################################################

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
 'dropout_layer', 'sequential_model', 'nn_fitter','model_compiler', 
 ]
params = [
    {'model_name': 'ridge', 'task': 'regression', 'model_type': 'linear_models', 'params': {'alpha': 1.0,}},
    {'model_name': 'lasso', 'task': 'regression', 'model_type': 'linear_models', 'params': {'alpha': 1.0,}},
    {'model_name': 'linear_regression', 'task': 'regression', 'model_type': 'linear_models', 'params': {}},
    {'model_name': 'sgd_regression', 'task': 'regression', 'model_type': 'linear_models', 'params': {'penalty': 'l2',}},
    {'model_name': 'elastic_net', 'task': 'regression', 'model_type': 'linear_models', 'params': {'alpha': 1.0, 'l1_ratio': 0.5,}},
    {'model_name': 'sgd_classifier', 'task': 'classification', 'model_type': 'linear_models', 'params': {'penalty': 'l2',}},
    {'model_name': 'ridge_classifier', 'task': 'classification', 'model_type': 'linear_models', 'params': {'alpha': 1.0,}},
    {'model_name': 'logistic_regression', 'task': 'classification', 'model_type': 'linear_models', 'params': {'penalty': 'l2','C': 1.0,}},
    {'model_name': 'rbf_svr', 'task': 'regression', 'model_type': 'svm', 'params': {'C': 1.0}},
    {'model_name': 'linear_svr', 'task': 'regression', 'model_type': 'svm', 'params': {'C': 1.0}},
    {'model_name': 'poly_svr', 'task': 'regression', 'model_type': 'svm', 'params': {'kernel': 'poly', 'C': 1.0}},
    {'model_name': 'sigmoid_svr', 'task': 'regression', 'model_type': 'svm', 'params': {'kernel': 'sigmoid', 'C': 1.0}},
    {'model_name': 'rbf_svc', 'task': 'classification', 'model_type': 'svm', 'params': {'C': 1.0}},
    {'model_name': 'linear_svc', 'task':'classification','model_type':'svm','params' :{'C': 1.0}},
    {'model_name':'poly_svc','task':'classification','model_type':'svm','params' :{'kernel':'poly', 'C': 1.0}},
    {'model_name':'sigmoid_svc','task':'classification','model_type':'svm','params' :{'kernel':'sigmoid', 'C': 1.0}},
    {'model_name':'bagging_regressor','task':'regression','model_type':'tree','params' :{}},
    {'model_name':'adaboost_regressor','task':'regression','model_type':'tree','params' :{}},
    {'model_name':'gradient_boosting_regressor','task':'regression','model_type':'tree','params' :{}},
    {'model_name':'decision_tree_regressor','task':'regression','model_type':'tree','params' :{'n_estimators' : 100}},
    {'model_name':'random_forest_regressor','task':'regression','model_type':'tree','params' :{'n_estimators' : 100}},
    {'model_name':'bagging_classifier','task':'classification','model_type':'tree','params' :{}},
    {'model_name':'adaboost_classifier','task':'classification','model_type':'tree','params' :{}},
    {'model_name':'gradient_boosting_classifier','task':'classification','model_type':'tree','params' :{}},
    {'model_name':'decision_tree_classifier','task':'classification','model_type':'tree','params' :{'n_estimators' : 100}},
    {'model_name':'random_forest_classifier','task':'classification','model_type':'tree','params' :{'n_estimators' : 100}},
    {'model_name':'gaussian_nb','task':'classification','model_type':'naive_bayes','params' :{}},
    {'model_name':'bernoulli_nb','task':'classification','model_type':'naive_bayes','params' :{}},
    {'model_name':'multinomial_nb','task':'classification','model_type':'naive_bayes','params' :{}},
    {'model_name':'knn_regressor', 'task': 'regression', 'model_type': 'knn', 'params': {'n_neighbors': 5,}},
    {'model_name': 'knn_classifier', 'task': 'classification', 'model_type': 'knn', 'params': {'n_neighbors': 5,}},
    
    {"model": 1, "X": 2, "y":3},
    {"model": 1, "X": 2},
    {"y_true": 1, "y_pred": 2, "params": {"metric": "mse"}},

    {"preprocessor_name": "maxabs_scaler", "preprocessor_type": "scaler", "params": {}},
    {"preprocessor_name": "normalizer", "preprocessor_type": "scaler", "params": {'norm': 'l2'}}, 
    {"preprocessor_name": "minmax_scaler", "preprocessor_type": "scaler", "params": {'feature_range': (0, 1)}}, 
    {"preprocessor_name": "robust_scaler", "preprocessor_type": "scaler", "params": {'quantile_range': (25.0, 75.0)}}, 
    {"preprocessor_name": "standard_scaler", "preprocessor_type": "scaler", "params": {'with_mean': True, 'with_std': True}}, 
    {"preprocessor_name": "label_encoder", "preprocessor_type": "encoder", "params": {}}, 
    {"preprocessor_name": "onehot_encoder", "preprocessor_type": "encoder", "params": {}}, 
    {"preprocessor_name": "ordinal_encoder", "preprocessor_type": "encoder", "params": {}}, 
    {"preprocessor_name": "label_binarizer", "preprocessor_type": "encoder", "params": {}}, 
    {"preprocessor_name": "knn_imputer",  "preprocessor_type": "imputer", "params": {'n_neighbors': 5}},
    {"preprocessor_name": "simple_imputer", "preprocessor_type": "imputer", "params": {'strategy': 'mean'}},
    {"preprocessor_name": "binarizer", "preprocessor_type": "binarizer", "params": {'threshold': 0.0}},
    
    {"preprocessor": 1, "data": 2},
    {"preprocessor": 1, "data": 2},
    {"preprocessor": 1, "data": 2},

    {"params": {"dataset_name": "iris"}},
    {"data": 1},
    {"data_1": 1, "data_2": 2},
    {"data": 1, "params": {"test_size": 0.2, "random_state": 42}},

    {"params": {"shape": [28, 28, 1]}},
    {"params": {"filters": 32, "kernel_size": (3, 3), "activation": "relu"}, "prev_node": 1},
    {"params": {"pool_size": (2, 2)}, "prev_node": 1},
    {"params": {}, "prev_node": 1},
    {"params": {"units": 128, "activation": "relu"}, "prev_node": 1},
    {"params": {"rate": 0.5}, "prev_node": 1},
    {"params": {}, "layer": 1},
    {"params": {"batch_size":20, "epochs":10}, "model": 1, "X": 2, "y": 3},
    {"params": {"optimizer": "sgd","loss": "categorical_crossentropy","metrics": ["accuracy"]}, "model": 1},
]
mapp = dict(zip(nodes, params))
with open('data_mapping.json', 'w') as f:
    json.dump(mapp, f, indent=4)
