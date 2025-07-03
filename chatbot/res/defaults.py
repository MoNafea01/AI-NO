import json
import os
import pandas as pd
import json


base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
schema_dir = os.path.join(base_dir, 'project', 'core', 'schema.xlsx')

def create_data_mapping():
    schema = pd.read_excel(schema_dir, sheet_name="Sheet1")
    schema = schema[['node_name', 'params', 'input_channels', 'api_call']]
    schema.fillna('[]', inplace=True)
    schema['params'] = schema['params'].apply(lambda x: eval(x))
    schema['input_channels'] = schema['input_channels'].apply(lambda x: eval(x))
    input_channels = schema['input_channels'].tolist()
    params = schema['params'].tolist()

    api_ref = schema['api_call'].tolist()
    node_name = schema['node_name'].tolist()
    new_params = []
    for i, param in enumerate(params):
        d = {}
        x = {}
        for sub_param in param:
            x.update({sub_param['name'].strip(): sub_param['default']})

        if api_ref[i] in ['create_model/', 'create_preprocessor/']:
            d.update(x)
        else:
            d.update({"params": x})

        new_params.append(d)

    chnl_dict = {}
    for i, chnl in enumerate(input_channels):
        if len(chnl) > 0:
            chnl_dict.update({node_name[i]: chnl})
        else:
            chnl_dict.update({node_name[i]: []})

    new_params = {k: v for k, v in zip(schema['node_name'].tolist(), new_params)}


    merged_nodes = {}

    for key in set(chnl_dict) | set(new_params):
        merged = {}
        
        # Add inputs as ID placeholders
        for inp in chnl_dict.get(key, []):
            merged[inp] = f"{inp}_id"

        # Merge in parameters
        params = new_params.get(key, {})
        if isinstance(params, dict):
            for p_key, p_val in params.items():
                # Special handling: nest under 'params' only if 'params' exists as a key
                if p_key == 'params':
                    merged['params'] = {}
                    for inner_k, inner_v in p_val.items():
                        merged['params'][inner_k] = inner_v
                else:
                    merged[p_key] = p_val

        merged_nodes[key] = merged
    

    with open(os.path.join(base_dir, 'chatbot', 'res', 'data_mapping.json'), 'w') as f:
        json.dump(merged_nodes, f, indent=4)

if __name__ == '__main__':
    create_data_mapping()
    print("Data mapping created successfully.")

editable = [
    'alpha', 'penalty', 'C', 'kernel', 'l1_ratio', 'n_neighbors', 'n_estimators',
    'feature_range', 'quantile_range', 'with_mean', 'with_std', 'norm',
    'strategy', 'threshold', 'batch_size', 'epochs', 'filters', 'kernel_size',
    'activation', 'pool_size', 'units', 'rate', 'optimizer', 'loss',
    'metrics', 'shape', 'test_size', 'random_state', 'dataset_name',
    'data', 'data_1', 'data_2', 'prev_node', 'layer', 'nn_model', 'compiled_model',
    'X', 'y', 'y_true', 'y_pred', 'metric', 'preprocessor', "<user_name>", "<password>",
    "<project_id>", "<node_name>", "<node_id>", "<args>"
]
