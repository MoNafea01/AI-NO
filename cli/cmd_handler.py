from handlers.user_handler import handle_user_command
from handlers.project_handler import handle_project_command
from handlers.workflow_handler import handle_workflow_command
from handlers.block_handler import handle_block_command
import re
create_user, select_user, remove_user, make_admin = handle_user_command, handle_user_command, handle_user_command, handle_user_command
create_project, select_project, remove_project, deselect_project, list_projects = handle_project_command, handle_project_command, handle_project_command, handle_project_command, handle_project_command
create_workflow, select_workflow, remove_workflow, deselect_workflow, list_workflows, finish_workflow = handle_workflow_command, handle_workflow_command, handle_workflow_command, handle_workflow_command, handle_workflow_command, handle_workflow_command
create_block, edit_block, remove_block, explore_block, list_blocks = handle_block_command, handle_block_command, handle_block_command, handle_block_command, handle_block_command
get_recent = handle_user_command
def cmd_handler(command,mode=False):
    """
    Handles the command entered by the user.
    if mode is True, the command is prefixed with "aino".
    """
    try:
        if mode:
            command = "aino " + command


        args = command.split()  # Split the command into a list of arguments, ["aino", command] 

        if not args:
            return "No command entered."

        cmd = args[0]
        if cmd == 'nomode':
            return "Mode deactivated."

        elif cmd == "aino":
            if len(args) == 1:
                return "No sub-command entered."
            sub_cmd = args[1]
            if len(args) == 1:
                return handle_sub_command(sub_cmd)
            return handle_sub_command(sub_cmd, args[2:])
        
        return f"Unknown command: {cmd}"
    except Exception as e:
        return f"Error: {str(e)}"

def handle_sub_command(sub_cmd, args):
    """
    Handles the sub-command entered by the user.
    takes the sub-command and the arguments as input.
    """
    commands = {"create_user": create_user, "mkusr": create_user,
        "select_user": select_user, "selusr": select_user,
        "remove_user": remove_user, "rmusr": remove_user,
        "make_admin": make_admin, "mkadm": make_admin,

        "create_project": create_project, "mkprj": create_project,
        "select_project": select_project, "selprj": select_project,
        "deselect_project": deselect_project, "dselprj": deselect_project,
        "list_projects": list_projects, "lsprj": list_projects,
        "remove_project": remove_project, "rmprj": remove_project,

        "create_workflow": create_workflow, "mkwf": create_workflow,
        "select_workflow": select_workflow, "selwf": select_workflow,
        "deselect_workflow": deselect_workflow, "dselwf": deselect_workflow,
        "list_workflows": list_workflows, "lswf": list_workflows,
        "finish_workflow": finish_workflow, "fnwf": finish_workflow,
        "remove_workflow": remove_workflow, "rmwf": remove_workflow,

        "make": create_block, "mkblk": create_block, 
        "edit": edit_block, "edblk": edit_block,
        "remove": remove_block, "rmblk": remove_block,
        "list_blocks": list_blocks, "lsblk": list_blocks,
        "explore": explore_block, "exblk": explore_block,

        "recent": get_recent,
        
        "list_commands": help_commands, "help": help_commands,
        "aino": activate_mode,
        "exit": exit_aino, "quit": exit_aino,
    }
    if len(args) == 0:
        arg = []
    else:
        # TODO: You will need to edit this part to handle multiple arguments.
        arg = args
    if sub_cmd in commands:
        return commands[sub_cmd](sub_cmd,arg)
    else:
        return f"Unknown sub-command: {sub_cmd}"

def help_commands(*args):
    """
    Provides a list of available commands.
    """
    return """
    Available commands:

    User commands:

        create_user <user_name> <password>
        select_user <user_name> <password>
        remove_user <user_name>
        make_admin  <user_name>

        -- Shortcuts --

        mkusr  <user_name> <password>
        selusr <user_name> <password>
        rmusr  <user_name>
        mkadm  <user_name>

        
    Project commands:

        create_project <project_name>
        select_project <project_name>
        remove_project <project_name>
        deselect_project
        list_projects

        -- Shortcuts --

        mkprj  <project_name>
        selprj <project_name>
        rmprj  <project_name>
        dselprj
        lsprj

        
    Workflow commands:

        create_workflow <workflow_name>
        select_workflow <workflow_name>
        remove_workflow <workflow_name>
        deselect_workflow
        list_workflows
        finish_workflow

        -- Shortcuts --

        mkwf  <workflow_name>
        selwf <workflow_name>
        rmwf  <workflow_name>
        dselwf
        lswf
        fnwf

        
    Block commands:

        make    <block_name> <args>
        edit    <block_name> <block_id> <args>
        remove  <block_name> <block_id>
        explore <block_name> <block_id>
        list_blocks
        
        -- Shortcuts --

        mkblk <block_name> <args>
        edblk <block_name> <block_id> <args>
        rmblk <block_name> <block_id>
        exblk <block_name> <block_id>
        lsblk
        

    General commands:
        recent
        help
    """

def activate_mode(*args):
    return "Mode activated."

def exit_aino(*args, **kwargs):
    import os
    from save_load import save_data_to_file
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data_store.json')
    save_data_to_file(path)
    return "Exiting Aino CMD Interface. Goodbye!"