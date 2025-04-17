from data_store import get_data_store
from handlers.mapper import mapper
import re, json, requests

def handle_block_command(sub_cmd, args):

    args = list(map(lambda x: re.sub(r'\s+', '', x),args))
    
    commands = {
        "make": create_block,               # block_name, args
        "edit": edit_block,                 # block_name, block_id, args
        "remove": remove_block,             # block_name, block_id
        "explore": explore_block,           # block_name, block_id
        "show": explore_block,              # block_name, block_id
        "list": list_blocks,                # None
        "ls": list_blocks,                  # None
    }
    
    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return False, f"Unknown node command: {sub_cmd}"
    

def create_block(*args):
    data_store = get_data_store()
    project = _get_active_project(data_store)
    project_id = get_data_store().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    if node_name not in mapper:
        return False, f"Node {node_name} not found in the mapper."
    query = mapper.get(node_name)
    args = eval(''.join(args[1:]))

    payload = send_request_to_api(args, query, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error creating Node"

    project.append(payload)
    return explore_block(node_name, payload.get('node_id'), project_id=project_id)


def edit_block(*args):
    data_store = get_data_store()
    project = _get_active_project(data_store)
    project_id = get_data_store().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    block_id = args[1]
    if node_name not in mapper:
        return False, f"Node {node_name} not found in the mapper."
    
    exp, i = find_block(block_id, project)
    if not exp:
        return False, f"Node {block_id} not found."

    query = mapper.get(node_name)
    args = eval(''.join(args[2:]))

    payload = send_request_to_api(args, query, method_type='put', node_id=block_id, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error Updating Node"
    
    project[i] = payload
    return explore_block(node_name, block_id, project_id=project_id)


def remove_block(*args):
    data_store = get_data_store()
    project = _get_active_project(data_store)
    project_id = get_data_store().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    block_id = args[1]

    if node_name not in mapper:
        return False, f"Node {node_name} not found in mapper."
    
    exp, i = find_block(block_id, project)
    if not exp:
        return False, f"Node {block_id} not found."
        
    query = mapper.get(node_name)
    args = []
    
    payload = send_request_to_api(args, query, method_type='delete', node_id=block_id, project_id=project_id)
    if not payload:
        project.pop(i)
        return True, f"Node {block_id} removed."
    if not isinstance(payload, dict):
        return False, "Error Removing Node"
    
    return False, f"Node {block_id} does not exist."

def list_blocks():
    data_store = get_data_store()
    project = _get_active_project(data_store)
    if project is None:
        return False, "No Project selected."
    ids = [block.get('node_id') for block in project]
    names = [block.get('node_name') for block in project]
    names_ids = zip(names, ids)
    return True, f"Nodes: \n{'\n'.join(map(str, names_ids))}"

def explore_block(*args, **kwargs):
    data_store = get_data_store()
    project = _get_active_project(data_store)
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    block_id = args[1]
    out = '0'
    if len(args) > 2:
        out = args[2]

    if node_name not in mapper:
        return False, f"Node {node_name} not found in the mapper."
    
    exp, _ = find_block(block_id, project)
    if not exp:
        return False, f"Node {block_id} not found."
    
    query = mapper.get(node_name)
    args = []

    project_id = kwargs.get("project_id", None)
    if not project_id:
        project_id = get_data_store().get("active_project")
    payload = send_request_to_api(args, query, method_type='get', node_id=block_id, project_id=project_id, output=out)
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

    return data_store["users"][user]["projects"][project_id]


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
        return None
    try:
        return response.json()
    except json.JSONDecodeError:
        print("Response is not JSON")
        return response
    
def find_block(block_id, project):
    for i, block in enumerate(project):
        if block.get('node_id') == int(block_id):
            return True, i
    return False, None
