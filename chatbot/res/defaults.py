import json

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
         'data_loader', 'splitter', 'joiner', 'train_test_split',
         'input_layer', 'conv2d_layer', 'maxpool2d_layer', 'flatten_layer', 'dense_layer', 
         'dropout_layer', 'sequential_model', 'nn_model_fitter', 'model_compiler', 
 ]

editable = [
    'alpha', 'penalty', 'C', 'kernel', 'l1_ratio', 'n_neighbors', 'n_estimators',
    'feature_range', 'quantile_range', 'with_mean', 'with_std', 'norm',
    'strategy', 'threshold', 'batch_size', 'epochs', 'filters', 'kernel_size',
    'activation', 'pool_size', 'units', 'rate', 'optimizer', 'loss',
    'metrics', 'shape', 'test_size', 'random_state', 'dataset_name',
    'data', 'data_1', 'data_2', 'prev_node', 'layer', 'nn_model', 'model', 'compiled_model',
    'X', 'y', 'y_true', 'y_pred', 'metric', 'preprocessor', "<user_name>", "<password>",
    "<project_id>", "<node_name>", "<node_id>", "<args>"
]


params = [{'alpha': 1.0,},
    {'alpha': 1.0,},
    {},
    {'penalty': 'l2',},
    {'alpha': 1.0, 'l1_ratio': 0.5,},
    {'penalty': 'l2',},
    {'alpha': 1.0,},
    {'penalty': 'l2','C': 1.0,},
    {'C': 1.0},
    {'C': 1.0},
    {'kernel': 'poly', 'C': 1.0},
    {'kernel': 'sigmoid', 'C': 1.0},
    {'C': 1.0},
    {'C': 1.0},
    {'kernel':'poly', 'C': 1.0},
    {'kernel':'sigmoid', 'C': 1.0},
    {},
    {},
    {},
    {'n_estimators' : 100},
    {'n_estimators' : 100},
    {},
    {},
    {},
    {'n_estimators' : 100},
    {'n_estimators' : 100},
    {},
    {},
    {},
    {'n_neighbors': 5,},
    {'n_neighbors': 5,},

    {"model": 1, "X": 2, "y":3},
    {"model": 1, "X": 2},
    {"y_true": 1, "y_pred": 2, "params": {"metric": "mse"}},

    {},
    {'norm': 'l2'},
    {'feature_range': (0, 1)}, 
    {'quantile_range': (25.0, 75.0)}, 
    {}, 
    {}, 
    {}, 
    {}, 
    {}, 
    {'n_neighbors': 5},
    {'strategy': 'mean'},
    {'threshold': 0.0},
    
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
    {"params": {"batch_size":20, "epochs":10}, "compiled_model": 1, "X": 2, "y": 3},
    {"params": {"optimizer": "sgd","loss": "categorical_crossentropy","metrics": ["accuracy"]}, "model": 1},
]

mapp = dict(zip(nodes, params))
with open('data_mapping.json', 'w') as f:
    json.dump(mapp, f, indent=4)
