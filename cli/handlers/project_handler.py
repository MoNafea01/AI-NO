from data_store import get_data_store
from .block_handler import send_request_to_api

def handle_project_command(sub_cmd, args):
    commands = {
        "create_project": create_project,       # project_id
        "mkprj": create_project,                # project_id
        "select_project": select_project,       # project_id
        "selprj": select_project,               # project_id
        "deselect_project": deselect_project,   # None
        "dselprj": deselect_project,            # None
        "list_projects": list_projects,         # None
        "lsprj": list_projects,                 # None
        "remove_project": remove_project,       # project_id
        "rmprj": remove_project,                # project_id
        "clear_project": clear_project,         # project_id
        "cls": clear_project,                   # project
    }

    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return False, f"Unknown project command: {sub_cmd}"


def create_project(project_id):
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
    data_store["users"][active_user]["projects"][project_id] = {}
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
        return True, project_id
    return False,  "Project does not exist."

def clear_project():
    data_store = get_data_store()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    active_project = data_store.get("active_project")
    if not active_project:
        return False, "No project selected."
    
    data_store["users"][active_user]["projects"][active_project] = []
    response = send_request_to_api([], "nodes/clear-project/", method_type="delete", project_id=active_project)

    return True, f"Project {active_project} cleared."
