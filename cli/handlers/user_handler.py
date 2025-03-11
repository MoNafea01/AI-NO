from data_store import get_data_store, set_data_store, load_backup_data
from save_load import save_data_to_file
import os

path = os.path.dirname(os.path.abspath(__file__)) + '/../'
data_file_path = path + 'data_store.json'

def handle_user_command(sub_cmd, args):

    commands = {
        "create_user": create_user,
        "mkusr": create_user,
        "select_user": select_user,
        "selusr": select_user,
        "remove_user": remove_user,
        "rmusr": remove_user,
        "make_admin": make_admin,
        "mkadm": make_admin,
        'recent': get_recent
    }

    if sub_cmd in commands:
        return commands[sub_cmd](*args)
    return f"Unknown user command: {sub_cmd}"


def create_user(username, password):
    data_store = get_data_store()
    if username not in data_store["users"]:
        data_store["users"][username] = {"password": password, "projects": {}}
        data_store["active_user"] = username

        if len(data_store['admin']) == 0 and len(data_store['users'].keys()) == 1:
            data_store['admin'].append(username)

        elif len(data_store['admin']) == 0 and len(data_store['users'].keys()) == 2:
            data_store['admin'].append(list(data_store['users'].keys())[0])

        save_data_to_file(data_file_path)
        return f"User {username} created."
    data_store["active_user"] = username
    return f"User {username} already exists."


def select_user(username, password):
    data_store = get_data_store()
    if username in data_store["users"] and data_store["users"][username]["password"] == password:
        data_store["active_user"] = username

        return f"User {username} selected."
    return "Invalid username or password."


def remove_user(username):
    data_store = get_data_store()
    if not is_sudo():
        return "You must be an admin to remove users."
    if username in data_store["users"]:
        del data_store["users"][username]
        if username in data_store["admin"]:
            data_store["admin"].remove(username)

        if len(data_store['users'].keys()) == 1:
            data_store['admin'].append(list(data_store['users'].keys())[0])
            
        save_data_to_file(data_file_path)
        return f"User {username} removed."
    return "User does not exist."


def make_admin(username):
    data_store = get_data_store()
    if not is_sudo():
        return "You must be an admin to make users admins."
    if username in data_store["users"]:
        data_store["admin"].append(username)
        save_data_to_file(data_file_path)
        return f"User {username} is now an admin."
    return "User does not exist."


def is_sudo():
    data_store = get_data_store()
    active_user = data_store["active_user"]
    admins = data_store["admin"]
    if active_user in admins:
        return True

def get_recent():
    import json
    with open(data_file_path) as json_file:
        json_data = json.load(json_file)
    active_user = json_data['active_user']
    active_project = json_data['active_project']
    active_workflow = json_data['active_workflow']
    # if active_project == '':
    #     return "No recent projects"
    if not (active_user or active_project or active_workflow):
        load_backup_data()
        return "Loaded Backup Data..."
    set_data_store(json_data)
    recent_workflow = get_data_store()['active_workflow']
    return recent_workflow
