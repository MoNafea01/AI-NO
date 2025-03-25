from data_store import get_data_store
from handlers.mapper import mapper
import re

def handle_block_command(sub_cmd, args):

    args = list(map(lambda x: re.sub(r'\s+', '', x),args))
    
    commands = {"make": create_block,       # block_name, args
        "mkblk": create_block,              # block_name, args
        "edit": edit_block,                 # block_name, block_id, args
        "edblk": edit_block,                # block_name, block_id, args
        "remove": remove_block,             # block_name, block_id
        "rmblk": remove_block,              # block_name, block_id
        "explore": explore_block,           # block_name, block_id
        "exblk": explore_block,             # block_name, block_id
        "list_blocks": list_blocks,         # None
        "lsblk": list_blocks,               # None
    }
    
    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return False, f"Unknown block command: {sub_cmd}"
    

def create_block(*args):
    data_store = get_data_store()
    project = _get_active_project(data_store)
    project_id = get_data_store().get("active_project")
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    if node_name not in mapper:
        return False, f"Block {node_name} not found."
    query = mapper.get(node_name)
    args = eval(''.join(args[1:]))

    payload = send_request_to_api(args, query, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error creating block"

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
        return False, f"Block {node_name} not found."
    
    exp, i = find_block(block_id, project)
    if not exp:
        return False, f"Block {block_id} not found."

    query = mapper.get(node_name)
    args = eval(''.join(args[2:]))

    payload = send_request_to_api(args, query, method_type='put', node_id=block_id, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error updating block"
    
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
        return False, f"Block {node_name} not found in mapper."
    
    exp, i = find_block(block_id, project)
    if not exp:
        return False, f"Block {block_id} not found."
        
    query = mapper.get(node_name)
    args = []
    
    payload = send_request_to_api(args, query, method_type='delete', node_id=block_id, project_id=project_id)
    if not payload:
        project.pop(i)
        return True, f"Block {block_id} removed."
    if not isinstance(payload, dict):
        return False, "Error removing block"
    
    return False, f"Block {block_id} does not exist."

def list_blocks():
    data_store = get_data_store()
    project = _get_active_project(data_store)
    if project is None:
        return False, "No Project selected."
    ids = [block.get('node_id') for block in project]
    names = [block.get('node_name') for block in project]
    names_ids = zip(names, ids)
    return True, f"Blocks: \n{'\n'.join(map(str, names_ids))}"

def explore_block(*args, **kwargs):
    data_store = get_data_store()
    project = _get_active_project(data_store)
    if project is None:
        return False, "No Project selected."
    
    node_name = args[0]
    block_id = args[1]

    if node_name not in mapper:
        return False, f"Block {node_name} not found."
    
    exp, _ = find_block(block_id, project)
    if not exp:
        return False, f"Block {block_id} not found."
    
    query = mapper.get(node_name)
    args = []

    project_id = kwargs.get("project_id", None)
    if not project_id:
        project_id = get_data_store().get("active_project")
    payload = send_request_to_api(args, query, method_type='get', node_id=block_id, project_id=project_id)
    if not isinstance(payload, dict):
        return False, "Error getting block"
    
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
    import json
    import requests

    node_id = kwargs.get("node_id", None)
    project_id = kwargs.get("project_id", None)
    query = query + f"?project_id={project_id}"

    if node_id:
        query = query + f"&node_id={node_id}"

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
    response = method[method_type](url, headers=headers, json=args, timeout=10)
    
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
