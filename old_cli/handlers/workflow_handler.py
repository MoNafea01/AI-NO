# from data_store import get_data_store

# def handle_workflow_command(sub_cmd, args):
#     commands = {
#         "create_workflow": create_workflow,
#         "mkwf": create_workflow,
#         "select_workflow": select_workflow,
#         "selwf": select_workflow,
#         "list_workflows": list_workflows,
#         "lswf": list_workflows,
#         "finish_workflow": finish_workflow,
#         "fnwf": finish_workflow,
#         "remove_workflow": remove_workflow,
#         "rmwf": remove_workflow,
#     }

#     if sub_cmd in commands:
#         return commands[sub_cmd](*args)
#     return f"Unknown workflow command: {sub_cmd}"


# def create_workflow(workflow_name):
#     data_store = get_data_store()
#     project = _get_active_project(data_store)
#     if project is None:
#         return "No project selected."
    
#     project['workflows'][workflow_name] = []
#     data_store["active_workflow"] = workflow_name
#     return f"Workflow {workflow_name} created."


# def select_workflow(workflow_name):
#     data_store = get_data_store()
#     project = _get_active_project(data_store)
#     if project is None:
#         return "No project selected."
    
#     if workflow_name in project['workflows']:
#         data_store["active_workflow"] = workflow_name
#         return f"Workflow {workflow_name} selected."
#     return "Workflow does not exist."

# def deselect_workflow():
#     data_store = get_data_store()
#     data_store["active_workflow"] = None
#     return "Workflow deselected."


# def remove_workflow(workflow_name):

#     data_store = get_data_store()
#     project = _get_active_project(data_store)
#     if project is None:
#         return "No project selected."
    
#     if workflow_name in project:
#         del project['workflows'][workflow_name]
#         return f"Workflow {workflow_name} removed."
#     return "Workflow does not exist."


# def list_workflows():
#     data_store = get_data_store()
#     project = _get_active_project(data_store)

#     if project is None:
#         return "No project selected."
#     return "Workflows: " + ", ".join(project['workflows'].keys())


# def finish_workflow():
#     return "Workflow finished."

# def _get_active_project(data_store):
#     """
#     Helper to retrieve the active project from the data store.
#     """
#     user = data_store.get("active_user")
#     project = data_store.get("active_project")
#     if not (user and project):
#         return None
    
#     return data_store["users"][user]["projects"][project]