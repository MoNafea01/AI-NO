from . import get_ds_name
def setup_config(node_name, idx, node_id):
    ds_name = get_ds_name(node_id)
    CONFIG = {
        'data_loader': {
            '1':{"message":f"data loaded: {ds_name}: X"},
            '2':{"message":f"data loaded: {ds_name}: y"},
        },
        'train_test_split': {
            '1':{"message":"Train data"},
            '2':{"message":"Test data"},
        },
        'splitter': {
            '1':{"message":"data_1"},
            '2':{"message":"data_2"},
        },
        'fitter_transformer': {
            '1':{"message":"Preprocessor fitted"},
            '2':{"message":"Preprocessor transformed"},
        },
    }
    return CONFIG[node_name][idx]