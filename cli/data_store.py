import json

# Initialize the in-memory data store
_data_store = {
    "users": {},
    "active_user": None,
    "active_project": None,
    "active_workflow": None,
    "admin": [],
}

def get_data_store():
    """
    Returns the data_store for centralized access.
    """
    global _data_store
    return _data_store

def set_data_store(new_data_store):
    """
    Updates the global data_store with new data.
    """
    global _data_store
    _data_store = new_data_store

def reset_data_store():
    """
    Resets the in-memory data store to its initial empty state.
    Useful for testing or resetting the system.
    """
    global _data_store
    _data_store = {
        "users": {},
        "active_user": None,
        "active_project": None,
        "active_workflow": None,
        "admin": [],
    }