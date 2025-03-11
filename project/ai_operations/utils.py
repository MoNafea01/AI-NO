MODEL = {
    'post': [{"model_name": "logistic_regression","model_type": "linear_models","task": "classification"},
             {"model_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\logistic_regression_2144678917760.pkl"}
             ],
    'put' : [{"model_name": "linear_regression","model_type": "linear_models","task": "regression"},
             {"model_path": r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\linear_regression_2144678909792.pkl"}
             ],
    }

DATA_LOADER = {
    'post': [{"dataset_name":"diabetes"},
             {"dataset_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\data.csv"},
             {"dataset_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\data_loader_1464733871296.pkl"}
             ],
    'put': [{"dataset_name":"iris"},
            {"dataset_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\data.csv"},
            {"dataset_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\data_loader_1464733871296.pkl"}
            ]
}




_requests_ = {
    'create_model': {
        'post': MODEL['post'],
        'put': MODEL['put'],
    },
    'data_loader': {
        'post': DATA_LOADER['post'],
        'put': DATA_LOADER['put'],
    },
}

_query_set_ = {
    'post': [{"name":"return_serialized", "values":[0, 1, 2]}],
    'get' : [{"name":"return_serialized", "values":[0, 1, 2]}, {"name":"output", "values":[0, 1, 2]}],
    'put' : [{"name":"return_serialized", "values":[0, 1, 2]},],
}
