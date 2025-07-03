# import json, os
# from data_store import get_data_store, set_data_store, reset_data_store
# file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data_store.json')

# def save_data_to_file(filepath=file_path):
#     """
#     Saves the current data_store to a JSON file.
#     """
#     data_store = get_data_store()
#     try:
#         with open(filepath, "w") as f:
#             json.dump(data_store, f, indent=4)
#     except Exception as e:
#         return f"Error saving data: {str(e)}"

# def load_data_from_file(filepath=file_path):
#     """
#     Loads the data_store from a JSON file.
#     """
#     try:
#         with open(filepath, "r") as f:
#             loaded_data = json.load(f)
#             actives = ['active_user', 'active_project']
#             for active in actives:
#                 loaded_data[active] = None
#             set_data_store(loaded_data)
#     except FileNotFoundError:
#         reset_data_store()
#     except json.JSONDecodeError:
#         return "Error: Invalid data file format."
#     except Exception as e:
#         return f"Error loading data: {str(e)}"

# def reset_data():
#     data = {
#         "users": {},
#         "active_user": None,
#         "active_project": None,
#         "admin": [],
#     }
#     return data

# def load_backup_data():
#     data = {
#         "users": 
#         {
#             "admin": 
#             {
#                 "password": "admin",
#                 "projects": 
#                 {
#                     "1": []
#                 }
#             }
#         }
#         ,
#     "active_user": "admin",
#     "active_project": "1",
#     "admin": ["admin"]
#     }
#     save_data(data)
#     return data

# def save_data(data, filepath=file_path):
#     """
#     Saves the current data_store to a JSON file.
#     """
#     with open(filepath, "w") as f:
#         json.dump(data, f, indent=4)

# def load_data(filepath=file_path):
#     """
#     Loads the data_store from a JSON file.
#     """
#     try:
#         with open(filepath, "r") as f:
#             data = json.load(f)
#             return data
#     except FileNotFoundError:
#         save_data(reset_data(), filepath)
#     except json.JSONDecodeError:
#         return "Error: Invalid data file format."
#     except Exception as e:
#         return f"Error loading data: {str(e)}"
