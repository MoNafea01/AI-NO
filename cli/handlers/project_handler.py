from data_store import get_data_store
from .block_handler import send_request_to_api

def handle_project_command(sub_cmd, args):
    commands = {
        "create_project": create_project,       # project_name, project_description
        "mkprj": create_project,                # project_name, project_description
        "select_project": select_project,       # project_id
        "selprj": select_project,               # project_id
        "deselect_project": deselect_project,   # None
        "dselprj": deselect_project,            # None
        "list_projects": list_projects,         # None
        "lsprj": list_projects,                 # None
        "remove_project": remove_project,       # project_id
        "rmprj": remove_project,                # project_id
        "clear_project": clear_project,         # project_id
        "get_project": get_project,             # project_id
        "load_project": load_project,
        "cls": clear_project,                   # project

    }

    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return False, f"Unknown project command: {sub_cmd}"


def create_project(project_name, project_description = "Project Created from CLI" ):
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
        
    response = send_request_to_api({"project_name":f"{project_name}",
                                    "project_description": f"{project_description}",
                                    }, "projects/", method_type="post")
    project_id = response.get("id")

    data_store["users"][active_user]["projects"][project_id] = []
    if not data_store['active_project']:
        data_store["active_project"] = project_id

    return True, f"Project {project_id} created."


def select_project(project_id):
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
    if project_id in data_store["users"][active_user]["projects"]:
        data_store["active_project"] = project_id
        return True, f"Project {project_id} selected."
    return False, "Project does not exist."


def deselect_project():
    data_store = get_data_store()
    data_store["active_project"] = None
    return True, "Project deselected."


def list_projects():
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
    
    projects = data_store["users"][active_user]["projects"]
    return True, "Projects: " + ", ".join(projects.keys())


def remove_project(project_id):
    data_store = get_data_store()
    active_user = data_store['active_user']
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]
    if project_id in projects:
        del projects[project_id]
        print( f"Project {project_id} removed.")
        response = send_request_to_api([], f"projects/{project_id}", method_type="delete")
        return True, project_id
    return False,  "Project does not exist."

def clear_project(project_id):
    data_store = get_data_store()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]
    
    if project_id in projects:
        data_store["users"][active_user]["projects"][project_id] = []
        response = send_request_to_api([], "clear_nodes/", method_type="delete", project_id=project_id)

    return True, f"Project {project_id} cleared."

def get_project(project_id):
    data_store = get_data_store()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]

    if project_id in projects:
        response = send_request_to_api([], "nodes/", method_type="get", project_id=project_id)
    return True, response

def load_project(project_id):
    data_store = get_data_store()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]

    response = send_request_to_api([], "nodes/", method_type="get", project_id=project_id)
    if project_id in projects:
        projects[project_id] = response 
    return True, response