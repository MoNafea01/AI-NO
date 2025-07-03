from save_load import load_data, save_data
from utils.defaults import default_data, Models, Preprocessors
import re, json, requests
import json, os

mapper_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'utils', 'mapper.json'))
with open(mapper_dir, 'r') as f:
    mapper = json.load(f)
    
DICT_NODES = ['data', 'data_1', 'data_2', 'X', 
              'y', 'model', 'y_true', 'y_pred', 
              'preprocessor', 'prev_node', 'layer', 'node', 
              'compiled_model', 'nn_model', 'fitted_model', 'fitted_preprocessor']


def eval_params(args):
    """
    Evaluates the parameters passed as a list of strings.
    It can handle lists, dictionaries, tuples, integers, floats, and strings.
    """
    params = {}
    if len(args) >= 1:
        for (key, val) in args.items():
            if val.startswith('[') or val.startswith('{') or val.startswith('('):
                try:
                    val = json.loads(val)
                    params[key] = val
                except json.JSONDecodeError:
                    pass
            elif val.isdigit():
                params[key] = int(val)
            elif re.match(r'^\d+\.\d+$', val):
                params[key] = float(val)
            else:
                params[key] = val
    return params


def extract_model_info(model_name, args):
    model_params = eval_params(args)
    
    model_info = None
    for i, param in enumerate(default_data):
        if model_name == param.get("model_name"):
            model_info = default_data[i]
            break
    model_info['params'].update(model_params) if model_params else {}
    return model_info


def extract_preprocess_info(preprecessor_name, args):
    preprocessor_params = eval_params(args)
    
    preprocessor_info = None

    for i,param in enumerate(default_data):
        if preprecessor_name == param.get('preprocessor_name'):
            preprocessor_info = default_data[i]
            break
    preprocessor_info['params'].update(preprocessor_params) if preprocessor_params else {}
    return preprocessor_info


def other_node_info(node_name, args):
    node_params = {'params': {}}
    for key, val in args.items():
        if key not in DICT_NODES:
            node_params['params'][key] = val
        elif key in DICT_NODES:
            node_params[key] = val
    params = eval_params(node_params['params'])
    node_params.pop('params', None)
    other_inputs = eval_params(node_params)
    node_params.update({'params': params, **other_inputs})
    
    node_info = None

    for i, param in enumerate(default_data):
        if node_name == param.get("node_name"):
            node_info = default_data[i]
            break
    node_info.pop('node_name', None)
    node_info.update(node_params) if node_params else {}
    return node_info


def extract_node_info(node_name, args):
    if node_name in Models:
        return extract_model_info(node_name, args)
    elif node_name in Preprocessors:
        return extract_preprocess_info(node_name, args)
    else:
        return other_node_info(node_name, args)


def mk_node(*args):
    data_store = load_data()
    project = _get_active_project(data_store)
    project_id = load_data().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    if node_name not in mapper:
        return False, f"Node {node_name} not found in the mapper."
    
    args = extract_node_info(node_name, args[1])
    query = mapper.get(node_name)

    sucess, payload = send_request_to_api(args, query, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error creating Node"
    
    if payload.get('error'):
        return False, payload.get('error')
    
    project.append(payload)
    save_data(data_store)
    return ex_node(node_name, payload.get('node_id'), output=0, project_id=project_id)


def ed_node(*args):
    data_store = load_data()
    project = _get_active_project(data_store)
    project_id = load_data().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    node_id = args[1]
    if node_name not in mapper:
        return False, f"Node {node_name} not found in the mapper."
    
    exp, i = find_node(node_id, project)
    if not exp:
        return False, f"Node {node_id} not found."

    query = mapper.get(node_name)
    args = extract_node_info(node_name, args[2])

    sucess, payload = send_request_to_api(args, query, method_type='put', node_id=node_id, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error Updating Node"

    if payload.get('error'):
        return False, payload.get('error')
    
    project[i] = payload
    save_data(data_store)
    return ex_node(node_name, node_id, output=0, project_id=project_id)


def rm_node(*args):
    data_store = load_data()
    project = _get_active_project(data_store)
    project_id = load_data().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    node_id = args[1]

    if node_name not in mapper:
        return False, f"Node {node_name} not found in mapper."
    
    exp, i = find_node(node_id, project)
    if not exp:
        return False, f"Node {node_id} not found."
        
    query = mapper.get(node_name)
    args = []
    
    sucess, payload = send_request_to_api(args, query, method_type='delete', node_id=node_id, project_id=project_id)
    if not payload:
        project.pop(i)
        return True, f"Node {node_id} removed."
    if not isinstance(payload, dict):
        return False, "Error Removing Node"
    
    return False, f"Node {node_id} does not exist."

def ls_node():
    data_store = load_data()
    project = _get_active_project(data_store)
    if project is None:
        return False, "No Project selected."
    ids = [node.get('node_id') for node in project]
    names = [node.get('node_name') for node in project]
    names_ids = zip(names, ids)
    return True, f"Nodes: \n{'\n'.join(map(str, names_ids))}"

def ex_node(*args, **kwargs):
    data_store = load_data()
    project = _get_active_project(data_store)
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    node_id = args[1]
    out = kwargs.get('output')

    if node_name not in mapper:
        return False, f"Node {node_name} not found in the mapper."
    
    exp, _ = find_node(node_id, project)
    if not exp:
        return False, f"Node {node_id} not found."
    
    query = mapper.get(node_name)
    args = []

    project_id = kwargs.get("project_id", None)
    if not project_id:
        project_id = load_data().get("active_project")
    sucess, payload = send_request_to_api(args, query, method_type='get', node_id=node_id, project_id=project_id, output=out)
    if not isinstance(payload, dict):
        return False, "Error getting Node"
    return True, payload

def _get_active_project(data_store):
    """
    Helper to retrieve the active Project from the data store.
    """
    user = data_store.get("active_user")
    project_id = data_store.get("active_project")
    if not (user and project_id):
        return None

    return data_store["users"][user]["projects"][str(project_id)]


def send_request_to_api(args, query="create_model/", method_type="post", **kwargs):

    node_id = kwargs.get("node_id", None)
    project_id = kwargs.get("project_id", None)
    output = kwargs.get("output", None)

    method ={
        "post": requests.post,
        "get": requests.get,
        "put": requests.put,
        "delete": requests.delete
    }
    url = f"http://localhost:8000/api/{query}"
    headers = {
        'Content-Type': 'application/json',
        "Accept": "application/json"
    }
    response = method[method_type](url, headers=headers, json=args, params={"project_id": project_id, "node_id": node_id,
                                                                            "output": output}, timeout=10)
    
    if response.text == "":
        return False, None
    try:
        return True, response.json()
    except json.JSONDecodeError:
        print("Response is not JSON")
        return False, response
    
def find_node(node_id, project):
    for i, node in enumerate(project):
        if node.get('node_id') == int(node_id):
            return True, i
    return False, None
