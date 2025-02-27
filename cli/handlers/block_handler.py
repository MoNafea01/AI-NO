from data_store import get_data_store
import re

def handle_block_command(sub_cmd, args):

    args = list(map(lambda x: re.sub(r'\s+', '', x),args))
    
    commands = {
        "make": create_block,
        "mkblk": create_block,
        "edit": edit_block,
        "edblk": edit_block,
        "list_blocks": list_blocks,
        "lsblk": list_blocks,
        "remove": remove_block,
        "rmblk": remove_block,
        "explore": explore_block,
        "exblk": explore_block
    }
    
    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return f"Unknown block command: {sub_cmd}"
    

def create_block(block_name, ports, params):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."

    workflow[block_name] = {"ports": ports, 
                            "params": params}
    return f"Block {block_name} created with ports {ports} and params {params}."


def edit_block(block_name, ports, params):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."

    if block_name in workflow:
        workflow[block_name].update({"ports": ports, "params": params})
        return f"Block {block_name} updated."
    return f"Block {block_name} does not exist."


def remove_block(block_name):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."
    
    if block_name in workflow:
        del workflow[block_name]
        return f"Block {block_name} removed."
    return f"Block {block_name} does not exist."


def list_blocks():
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."

    return "Blocks: " + ", ".join(workflow.keys())

def explore_block(block_name):
    data_store = get_data_store()
    workflow = _get_active_workflow(data_store)
    if workflow is None:
        return "No workflow selected."

    if block_name in workflow:
        return f"Block {block_name} has ports {workflow[block_name]['ports']} and params {workflow[block_name]['params']}."
    return f"Block {block_name} does not exist."

def _get_active_workflow(data_store):
    """
    Helper to retrieve the active workflow from the data store.
    """
    user = data_store.get("active_user")
    project = data_store.get("active_project")
    workflow = data_store.get("active_workflow")
    if not (user and project and workflow):
        return None

    return data_store["users"][user]["projects"][project][workflow]
