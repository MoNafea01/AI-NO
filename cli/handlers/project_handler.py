from data_store import get_data_store

def handle_project_command(sub_cmd, args):
    commands = {
        "create_project": create_project,
        "mkprj": create_project,
        "select_project": select_project,
        "selprj": select_project,
        "deselect_project": deselect_project,
        "dselprj": deselect_project,
        "list_projects": list_projects,
        "lsprj": list_projects,
        "remove_project": remove_project,
        "rmprj": remove_project,
    }

    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return f"Unknown project command: {sub_cmd}"


def create_project(project_name):
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return "No user selected."
    data_store["users"][active_user]["projects"][project_name] = {}
    data_store["active_project"] = project_name
    return f"Project {project_name} created."


def select_project(project_name):
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return "No user selected."
    if project_name in data_store["users"][active_user]["projects"]:
        data_store["active_project"] = project_name
        return f"Project {project_name} selected."
    return "Project does not exist."


def deselect_project():
    data_store = get_data_store()
    data_store["active_project"] = None
    return "Project deselected."


def list_projects():
    data_store = get_data_store()
    active_user = data_store["active_user"]
    if not active_user:
        return "No user selected."
    
    projects = data_store["users"][active_user]["projects"]
    return "Projects: " + ", ".join(projects.keys())


def remove_project(project_name):
    data_store = get_data_store()
    active_user = data_store['active_user']
    if not active_user:
        return "No user selected."
    projects = data_store['users'][active_user]["projects"]
    if project_name in projects:
        del projects[project_name]
        print( f"Project {project_name} removed.")
        return project_name
    print( "Project does not exist.")
    return None