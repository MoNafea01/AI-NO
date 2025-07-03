from save_load import load_data, save_data
from .node_handler import send_request_to_api

def mk_prj(project_name, project_description = "Project Created from CLI" ):
    data_store = load_data()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
        
    sucess, response = send_request_to_api({"project_name":f"{project_name}",
                                    "project_description": f"{project_description}",
                                    }, "projects/", method_type="post")
    project_id = response.get("id")

    data_store["users"][active_user]["projects"][str(project_id)] = []
    if not data_store['active_project']:
        data_store["active_project"] = project_id
    
    save_data(data_store)
    return True, f"Project {project_id} created."

def sel_prj(project_id):
    data_store = load_data()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
    
    if project_id in data_store["users"][active_user]["projects"]:
        data_store["active_project"] = project_id
        save_data(data_store)
        return True, f"Project {project_id} selected."
    
    sucess, response = send_request_to_api([], f"projects/{project_id}", method_type="get").get("id", None)
    if response:
        data_store["active_project"] = project_id
        status, nodes = load_prj(project_id)
        if status:
            data_store["users"][active_user]["projects"][project_id] = nodes
            save_data(data_store)
            return True, f"Project {project_id} selected."
        else:
            return False, "Failed to load project nodes."
    
    return False, "Project does not exist."

def dsel_prj():
    data_store = load_data()
    data_store["active_project"] = None
    save_data(data_store)
    return True, "Project deselected."

def ls_prj():
    data_store = load_data()
    active_user = data_store["active_user"]
    if not active_user:
        return False, "No user selected."
    
    projects = data_store["users"][active_user]["projects"]
    return True, "Projects: " + ", ".join(projects.keys())

def rm_prj(project_id):
    data_store = load_data()
    active_user = data_store['active_user']
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]
    if project_id in projects:
        del projects[project_id]
        print( f"Project {project_id} removed.")
        sucess, response = send_request_to_api([], f"projects/{project_id}/", method_type="delete")
        save_data(data_store)
        return True, project_id
    return False,  "Project does not exist."

def cl_prj(project_id):
    data_store = load_data()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]
    
    if project_id in projects:
        data_store["users"][active_user]["projects"][project_id] = []
        sucess, response = send_request_to_api([], "clear_nodes/", method_type="delete", project_id=project_id)
        save_data(data_store)
    return True, f"Project {project_id} cleared."

def get_prj(project_id):
    data_store = load_data()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]

    if project_id in projects:
        sucess, response = send_request_to_api([], "nodes/", method_type="get", project_id=project_id)
        if sucess:
            data_store['users'][active_user]["projects"][project_id] = response
            save_data(data_store)
    return True, response

def load_prj(project_id):
    data_store = load_data()
    active_user = data_store.get("active_user")
    if not active_user:
        return False, "No user selected."
    projects = data_store['users'][active_user]["projects"]

    sucess, response = send_request_to_api([], "nodes/", method_type="get", project_id=project_id)
    if sucess:
        projects[project_id] = response 
        save_data(data_store)
    
    return True, response
