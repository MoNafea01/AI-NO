from handlers.user_handler import handle_user_command
from handlers.project_handler import handle_project_command
from handlers.block_handler import handle_block_command
import re
create_user, select_user, remove_user, make_admin, get_recent = (handle_user_command,) * 5
(create_project, select_project, remove_project, deselect_project, 
 list_projects, clear_project, get_project, load_project) = (handle_project_command,) * 8
create_block, edit_block, remove_block, explore_block, list_blocks = (handle_block_command,) * 5

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
    commands = {
        "register": create_user,
        "login": select_user,
        "remove_user": remove_user, "rmusr": remove_user,
        "make_admin": make_admin, "mkadm": make_admin,

        "create_project": create_project, "mkprj": create_project,
        "select_project": select_project, "selprj": select_project,
        "deselect_project": deselect_project, "dselprj": deselect_project,
        "list_projects": list_projects, "lsprj": list_projects,
        "remove_project": remove_project, "rmprj": remove_project,
        "clear_project": clear_project, "cls": clear_project,
        "get_project": get_project,
        "load_project": load_project,

        "make": create_block,
        "edit": edit_block,
        "remove": remove_block,
        "list": list_blocks, "ls": list_blocks,
        "show": explore_block,

        "recent": get_recent,
        
        "list_commands": help_commands, "help": help_commands,
        "aino": activate_mode,
        "exit": exit_aino, "quit": exit_aino,
    }
    if len(args) == 0:
        arg = []
    else:
        arg = args
    if sub_cmd in commands:
        response = commands[sub_cmd](sub_cmd,arg)
        if isinstance(response, tuple):
            if response[0]:
                save()
            return response[1]
    
        return response

    else:
        return f"Unknown sub-command: {sub_cmd}"

def help_commands(*args):
    """
    Provides a list of available commands.
    """
    return """
    Available commands:

User commands:
	register    <user_name> <password>	// Register a new user
	login 	    <user_name> <password>	// Login to a user 
	remove_user <user_name>			// remove a user (you have to be admin to do that)
	make_admin  <user_name>			// make a user as an admin (you have to be admin to do that)

	----- Shortcuts -----

	rmusr  <user_name>
	mkadm  <user_name>

Project commands:
	create_project <project_id>		// create a project
	select_project <project_id>		// select a project
	remove_project <project_id>		// remove a project
	deselect_project			// deselect a project
	list_projects				// list all projects
	clear_project  <project_id>		// clear all nodes in a project
    load_project   <project_id>     // loads a poject from database
	get_project    <project_id>		// get all nodes in a project

	----- Shortcuts -----

	mkprj  <project_id>
	selprj <project_id>
	rmprj  <project_id>
	dselprj
	lsprj
	cls    <project_id>
    
node commands:
	make    <node_name> <args>		// create a node
	edit    <node_name> <node_id> <args>	// update an existing node
	remove  <node_name> <node_id>		// remove an existing node
	show	<node_name> <node_id>		// get a node
	list  					// list all nodes
    
	----- Shortcuts -----
	
	ls
    
General commands:
	recent					// get recent project with recent user automatically
	help					// list all possible commands
	exit | quit				// exit the program
    """

def activate_mode(*args):
    return "Mode activated."

def exit_aino(*args, **kwargs):
    save()
    return "Exiting Aino CMD Interface. Goodbye!"

def save(*args, **kwargs):
    import os
    from save_load import save_data_to_file
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data_store.json')
    save_data_to_file(path)
    return "Data saved."
