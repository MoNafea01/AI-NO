import json
from data_store import get_data_store, set_data_store, reset_data_store

def save_data_to_file(filepath="data_store.json"):
    """
    Saves the current data_store to a JSON file.
    """
    data_store = get_data_store()
    try:
        with open(filepath, "w") as f:
            json.dump(data_store, f, indent=4)
    except Exception as e:
        return f"Error saving data: {str(e)}"

def load_data_from_file(filepath="data_store.json"):
    """
    Loads the data_store from a JSON file.
    """
    try:
        with open(filepath, "r") as f:
            loaded_data = json.load(f)
            actives = ['active_user', 'active_project']
            for active in actives:
                loaded_data[active] = None
            set_data_store(loaded_data)
    except FileNotFoundError:
        reset_data_store()
    except json.JSONDecodeError:
        return "Error: Invalid data file format."
    except Exception as e:
        return f"Error loading data: {str(e)}"
