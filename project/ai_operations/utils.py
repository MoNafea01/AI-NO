MODEL = {
    'post': [{"model_name": "logistic_regression","model_type": "linear_models","task": "classification"},
             {"model_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\logistic_regression_2144678917760.pkl"}
             ],
    'put' : [{"model_name": "linear_regression","model_type": "linear_models","task": "regression"},
             {"model_path": r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\linear_regression_2144678909792.pkl"}
             ],
    }

FIT_MODEL = {
    'post': [{},
             {"model_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\logistic_regression_2144678917760.pkl"}
             ],
    'put' : [{},
             {"model_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\linear_regression_2144678909792.pkl"}
             ]
}

PREDICT_MODEL = {
    'post': [{},
             {"model_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\model_fitter_2291558202736.pkl"}
             ],
    'put' : [{},
             {"model_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\model_fitter_2291558202736.pkl"}
             ]
}

EVALUATE_MODEL = {
    'post': [{"params": {"metric": "mse"}},
             ],
    'put' : [{"params": {"metric": "r2"}},
             ]
}

DATA_LOADER = {
    'post': [{"params": {"dataset_name":"diabetes"}},
             {"dataset_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\data_loader_1464733871296.pkl"}
             ],
    'put': [{"params": {"dataset_name":"diabetes"}},
            {"dataset_path":r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\testing\data_loader_1464733871296.pkl"}
            ]
}

TR_TE_SP = {
        'post': [{"params": {"test_size": 0.2, "random_state": 42}},],
        'put': [{"params": {"test_size": 0.3, "random_state": 42}},],
}




_requests_ = {
    'create_model': {
        'post': MODEL['post'],
        'put': MODEL['put'],
    },
    'fit_model':{
        'post': FIT_MODEL['post'],
        'put': FIT_MODEL['put']
    },
    'predict_model': {
        'post': PREDICT_MODEL['post'],
        'put': PREDICT_MODEL['put'],
    },
    'evaluate_model': {
        'post': EVALUATE_MODEL['post'],
        'put': EVALUATE_MODEL['put'],
    },
    'data_loader': {
        'post': DATA_LOADER['post'],
        'put': DATA_LOADER['put'],
    },
    'train_test_split': {
        'post': TR_TE_SP['post'],
        'put': TR_TE_SP['put'],
    },
}

_query_set_ = {
    'get' : [{"name":"output", "values":[0, 1, 2]}]
}

