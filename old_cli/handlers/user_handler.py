# from data_store import get_data_store, set_data_store, load_backup_data
# from save_load import save_data_to_file
# from handlers.block_handler import send_request_to_api
# import os

# path = os.path.dirname(os.path.abspath(__file__)) + '/../'
# data_file_path = path + 'data_store.json'

# def handle_user_command(sub_cmd, args):
#     print("h1")

#     commands = {
#         "register": create_user,        # <username> <password>
#         "login": select_user,           # <username> <password>
#         "remove_user": remove_user,     # <username>
#         "rmusr": remove_user,           # <username>
#         "make_admin": make_admin,       # <username>
#         "mkadm": make_admin,            # <username>
#         'recent': get_recent
#     }

#     if sub_cmd in commands:
#         return commands[sub_cmd](*args)
#     return False, f"Unknown user command: {sub_cmd}"


# def create_user(username, password):
#     data_store = get_data_store()
#     if username not in data_store["users"]:
#         data_store["users"][username] = {"password": password, "projects": {}}
#         data_store["active_user"] = username

#         if len(data_store['admin']) == 0 and len(data_store['users'].keys()) == 1:
#             data_store['admin'].append(username)

#         elif len(data_store['admin']) == 0 and len(data_store['users'].keys()) == 2:
#             data_store['admin'].append(list(data_store['users'].keys())[0])

#         save_data_to_file(data_file_path)
#         return True, f"User {username} created."
#     data_store["active_user"] = username
#     return False, f"User {username} already exists."


# def select_user(username, password):
#     data_store = get_data_store()
#     if username in data_store["users"] and data_store["users"][username]["password"] == password:
#         data_store["active_user"] = username

#         return True, f"User {username} selected."
#     return False, "Invalid username or password."


# def remove_user(username):
#     data_store = get_data_store()
#     if not is_sudo():
#         return False, "You must be an admin to remove users."
#     if username in data_store["users"]:
#         del data_store["users"][username]
#         if username in data_store["admin"]:
#             data_store["admin"].remove(username)

#         if len(data_store['users'].keys()) == 1 and len(data_store['admin']) == 0:
#             data_store['admin'].append(list(data_store['users'].keys())[0])
            
#         save_data_to_file(data_file_path)
#         return True, f"User {username} removed."
#     return False, "User does not exist."


# def make_admin(username):
#     data_store = get_data_store()
#     if not is_sudo():
#         return False, "You must be an admin to make other users admins."
#     if username in data_store["users"]:
#         data_store["admin"].append(username)
#         save_data_to_file(data_file_path)
#         return True, f"User {username} is now an admin."
#     return False, "User does not exist."


# def is_sudo():
#     data_store = get_data_store()
#     active_user = data_store["active_user"]
#     admins = data_store["admin"]
#     if active_user in admins:
#         return True

# def get_recent():
#     import json
#     with open(data_file_path) as json_file:
#         json_data = json.load(json_file)
#     active_user = json_data['active_user']
#     active_project = json_data['active_project']

#     if not (active_user or active_project):
#         json_data = load_backup_data()
#         sucess, api_response = send_request_to_api([], "nodes/", method_type="get", project_id="1")
#         if api_response:
#             active_user = json_data['active_user']
#             active_project = json_data['active_project']
#             json_data['users'][active_user]['projects'][active_project] = api_response
    
#     set_data_store(json_data)
#     recent_project = get_data_store()['active_project']
#     return True, recent_project
