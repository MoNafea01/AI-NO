from data_store import get_data_store
from handlers.mapper import mapper
import re
# TODO: this module needs to be edited
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
    return f"Unknown block command: {sub_cmd}"
    

def create_block(*args):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."
    
    node_name = args[0]
    if node_name not in mapper:
        return f"Block {node_name} not found."
    query = mapper.get(node_name)
    args = eval(''.join(args[1:]))

    payload = send_request_to_api(args, query)
    if not isinstance(payload, dict):
        return "Error creating block"

    workflow.append(payload)
    block = explore_block(node_name, payload.get('node_id'))
    return f"{block}"


def edit_block(*args):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."
    
    node_name = args[0]
    block_id = args[1]
    if node_name not in mapper:
        return f"Block {node_name} not found."
    
    exp, i = find_block(block_id, workflow)
    if not exp:
        return f"Block {block_id} not found."

    query = mapper.get(node_name)
    args = eval(''.join(args[2:]))

    payload = send_request_to_api(args, query, method_type='put', node_id=block_id)
    if not isinstance(payload, dict):
        return "Error updating block"
    
    workflow[i] = payload
    return f"Block {block_id} updated."


def remove_block(*args):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."
    
    node_name = args[0]
    block_id = args[1]

    if node_name not in mapper:
        return f"Block {node_name} not found in mapper."
    
    exp, i = find_block(block_id, workflow)
    if not exp:
        return f"Block {block_id} not found."
        
    query = mapper.get(node_name)
    args = []
    
    payload = send_request_to_api(args, query, method_type='delete', node_id=block_id)
    if not payload:
        workflow.pop(i)
        return f"Block {block_id} removed."
    if not isinstance(payload, dict):
        return "Error removing block"
    
    return f"Block {block_id} does not exist."

def list_blocks():
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."

    ids = [block.get('node_id') for block in workflow]
    return f"Blocks: {', '.join(map(str, ids))}"

def explore_block(*args):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."
    
    node_name = args[0]
    block_id = args[1]

    if node_name not in mapper:
        return f"Block {node_name} not found."
    
    exp, i = find_block(block_id, workflow)
    if not exp:
        return f"Block {block_id} not found."
    
    query = mapper.get(node_name)
    args = []

    payload = send_request_to_api(args, query, method_type='get', node_id=block_id)
    if not isinstance(payload, dict):
        return "Error getting block"
    
    return f"""Block {block_id}: 
    name: {payload.get('node_name', "default")}
    type: {payload.get('node_type', 'default')}
    task: {payload.get('task', 'default')}
    children: {payload.get('children', 'default')}
    params: {payload.get('params', 'default')}."""

def _get_active_project(data_store):
    """
    Helper to retrieve the active workflow from the data store.
    """
    user = data_store.get("active_user")
    project = data_store.get("active_project")
    if not (user and project):
        return None

    return data_store["users"][user]["projects"][project]

def _get_active_workflow(data_store):
    """
    Helper to retrieve the active workflow from the data store.
    """
    project = _get_active_project(data_store)
    workflow = data_store.get("active_workflow")
    if not (project and workflow):
        return None

    return project["workflows"][workflow]


def send_request_to_api(args, query="create_model/", method_type="post", **kwargs):
    import json
    import requests

    node_id = kwargs.get("node_id", None)
    
    if node_id:
        query = f"{query.rstrip('/')}/?node_id={node_id}"

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
    
def find_block(block_id, workflow):
    for i, block in enumerate(workflow):
        if block.get('node_id') == int(block_id):
            return True, i
    return False, None
