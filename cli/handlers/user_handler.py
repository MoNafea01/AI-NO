from save_load import save_data, load_data, load_backup_data
from handlers.node_handler import send_request_to_api

def reg_usr(username, password):
    data_store = load_data()
    if username not in data_store["users"]:
        data_store["users"][username] = {"password": password, "projects": {}}
        data_store["active_user"] = username

        if len(data_store['admin']) == 0 and len(data_store['users'].keys()) == 1:
            data_store['admin'].append(username)

        elif len(data_store['admin']) == 0 and len(data_store['users'].keys()) == 2:
            data_store['admin'].append(list(data_store['users'].keys())[0])

        save_data(data_store)
        return True, f"User {username} created."
    
    data_store["active_user"] = username
    save_data(data_store)
    return False, f"User {username} already exists."


def log_usr(username, password):
    data_store = load_data()
    if username in data_store["users"] and data_store["users"][username]["password"] == password:
        data_store["active_user"] = username
        save_data(data_store)
        return True, f"User {username} selected."
    return False, "Invalid username or password."


def rm_usr(username):
    data_store = load_data()
    if not is_sudo():
        return False, "You must be an admin to remove users."
    if username in data_store["users"]:
        del data_store["users"][username]
        if username in data_store["admin"]:
            data_store["admin"].remove(username)

        if len(data_store['users'].keys()) == 1 and len(data_store['admin']) == 0:
            data_store['admin'].append(list(data_store['users'].keys())[0])
            
        save_data(data_store)
        return True, f"User {username} removed."
    return False, "User does not exist."


def mk_adm(username):
    data_store = load_data()
    if not is_sudo():
        return False, "You must be an admin to make other users admins."
    if username in data_store["users"]:
        data_store["admin"].append(username)
        save_data(data_store)
        return True, f"User {username} is now an admin."
    return False, "User does not exist."


def is_sudo():
    data_store = load_data()
    active_user = data_store["active_user"]
    admins = data_store["admin"]
    if active_user in admins:
        return True

def get_recent():
    import json
    json_data = load_data()
    active_user = json_data['active_user']
    active_project = json_data['active_project']

    if not (active_user or active_project):
        json_data = load_backup_data()
        sucess, api_response = send_request_to_api([], "nodes/", method_type="get", project_id="1")
        if sucess:
            active_user = json_data['active_user']
            active_project = json_data['active_project']
            json_data['users'][active_user]['projects'][active_project] = api_response
    
    save_data(json_data)
    recent_project = load_data()['active_project']
    return True, recent_project
