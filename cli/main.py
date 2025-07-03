import argparse
import sys
from __init__ import *
from handlers.user_handler import reg_usr, log_usr, rm_usr, mk_adm, get_recent
from handlers.project_handler import mk_prj, sel_prj, dsel_prj, ls_prj, rm_prj, cl_prj, get_prj, load_prj
from handlers.node_handler import mk_node, ed_node, ex_node, rm_node, ls_node

def register(args):
    success, msg = reg_usr(args.username, args.password)
    print(msg)

def login(args):
    success, msg = log_usr(args.username, args.password)
    print(msg)

def remove_user(args):
    success, msg = rm_usr(args.username)
    print(msg)

def make_admin(args):
    success, msg = mk_adm(args.username)
    print(msg)


def create_project(args):
    status, msg = mk_prj(args.name, args.description)
    print(msg)

def select_project(args):
    status, msg = sel_prj(args.project_id)
    print(msg)

def remove_project(args):
    status, msg = rm_prj(args.project_id)
    print(msg)

def deselect_project(args):
    status, msg = dsel_prj()
    print(msg)

def list_projects(args):
    status, projects = ls_prj()
    print(projects)

def clear_project(args):
    status, nodes = cl_prj(args.project_id)
    print(nodes)

def load_project(args):
    status, nodes = load_prj(args.project_id)
    print(nodes)

def get_project(args):
    status, nodes = get_prj(args.project_id)
    print(nodes)


def create_node(node_name, kv_args):
    success, node_payload = mk_node(node_name, kv_args)
    if success:
        print(node_payload)

def edit_node(node_name, node_id, kv_args):
    success, node_payload = ed_node(node_name, node_id, kv_args)
    if success:
        print(node_payload)

def remove_node(node_name, node_id):
    success, msg = rm_node(node_name, node_id)
    print(msg)

def show_node(node_name, node_id, output):
    status, msg = ex_node(node_name, node_id, output=output)
    print(msg)

def list_nodes():
    status, nodes = ls_node()
    print(nodes)


def recent(args):
    success, msg = get_recent()
    print(msg)

def help(args):
    help_path = os.path.join(os.path.dirname(__file__), "utils", "help.txt")
    with open(help_path, "r") as f:
        help_text = f.read()
    print(help_text)
    
# more handler functions...

def main():    
    
    parser = argparse.ArgumentParser(prog="aino", description="AI-NO CLI")

    group = parser.add_mutually_exclusive_group(required=True)

    user_parser = argparse.ArgumentParser(add_help=False)
    user_subparsers = user_parser.add_subparsers(dest="user_cmd", required=True)

    reg = user_subparsers.add_parser("register", aliases=["reg"])
    reg.add_argument("username")
    reg.add_argument("password")
    reg.set_defaults(func=register)

    log = user_subparsers.add_parser("login", aliases=["log"])
    log.add_argument("username")
    log.add_argument("password")
    log.set_defaults(func=login)
    
    mkadm = user_subparsers.add_parser("make_admin", aliases=["mkadm"])
    mkadm.add_argument("username")
    mkadm.set_defaults(func=make_admin)
    
    rmusr = user_subparsers.add_parser("remove", aliases=["rm", "rmusr"])
    rmusr.add_argument("username")
    rmusr.set_defaults(func=remove_user)



    # project parser
    project_parser = argparse.ArgumentParser(add_help=False)
    project_subparsers = project_parser.add_subparsers(dest="project_cmd", required=True)

    cp = project_subparsers.add_parser("create")
    cp.add_argument("name")
    cp.add_argument("description", nargs='?', default="")
    cp.set_defaults(func=create_project)

    sp = project_subparsers.add_parser("select")
    sp.add_argument("project_id")
    sp.set_defaults(func=select_project)
    
    rp = project_subparsers.add_parser("remove", aliases=["rmprj", "rm"])
    rp.add_argument("project_id")
    rp.set_defaults(func=remove_project)
    
    dp = project_subparsers.add_parser("deselect")
    dp.set_defaults(func=deselect_project)
    
    lp = project_subparsers.add_parser("list", aliases=["lsprj", "ls"])
    lp.set_defaults(func=list_projects)
    
    cpj = project_subparsers.add_parser("clear", aliases=["cls"])
    cpj.add_argument("project_id")
    cpj.set_defaults(func=clear_project)
    
    lpj = project_subparsers.add_parser("load")
    lpj.add_argument("project_id")
    lpj.set_defaults(func=load_project)
    
    gp = project_subparsers.add_parser("get")
    gp.add_argument("project_id")
    gp.set_defaults(func=get_project)



    # node parser
    node_parser = argparse.ArgumentParser(add_help=False)
    node_subparsers = node_parser.add_subparsers(dest="node_cmd", required=True)

    cn = node_subparsers.add_parser("create")
    cn.add_argument("node_name")
    cn.add_argument("args", nargs=argparse.REMAINDER)
    cn.set_defaults(func=create_node)

    en = node_subparsers.add_parser("edit")
    en.add_argument("node_name")
    en.add_argument("node_id")
    en.add_argument("args", nargs=argparse.REMAINDER)
    en.set_defaults(func=edit_node)
    
    rn = node_subparsers.add_parser("remove", aliases=["rm"])
    rn.add_argument("node_name")
    rn.add_argument("node_id")
    rn.set_defaults(func=remove_node)
    
    sn = node_subparsers.add_parser("show")
    sn.add_argument("node_name")
    sn.add_argument("node_id")
    sn.set_defaults(func=show_node)
    
    ln = node_subparsers.add_parser("list", aliases=["ls"])
    ln.set_defaults(func=list_nodes)

    general_parser = argparse.ArgumentParser(add_help=False)
    general_subparsers = general_parser.add_subparsers(dest="general_cmd", required=True)
    rc = general_subparsers.add_parser("recent", aliases=["rec"])
    rc.set_defaults(func=recent)
    
    hlp = general_subparsers.add_parser("help", aliases=["h"])
    hlp.set_defaults(func=help)

    # Add them to mutually exclusive group as options
    group.add_argument("--user", nargs=argparse.REMAINDER, help="User commands")
    group.add_argument("--project", nargs=argparse.REMAINDER, help="Project commands")
    group.add_argument("--node", nargs=argparse.REMAINDER, help="Node commands")
    group.add_argument("--general", nargs=argparse.REMAINDER, help="General commands")

    # Parse known args first to detect the main group
    args, _ = parser.parse_known_args()
    
    if args.node:
        if len(args.node) < 1:
            print("Usage: --node <method> <argumets>")
            sys.exit(1)

        command = args.node[0]
        if command == "create":
            if len(args.node) < 2:
                print("Usage: --node create <node_name> key=value ...")
                sys.exit(1)
            node_name = args.node[1]
            kv_args = parse_key_value_args(args.node[2:])
            create_node(node_name, kv_args)
            
        elif command == "edit":
            if len(args.node) < 3:
                print("Usage: --node edit <node_name> <node_id> key=value ...")
                sys.exit(1)
            node_name = args.node[1]
            node_id = args.node[2]
            kv_args = parse_key_value_args(args.node[3:])
            edit_node(node_name, node_id, kv_args)
            
        elif command == "remove" or command == "rm":
            if len(args.node) < 3:
                print("Usage: --node remove <node_name> <node_id>")
                sys.exit(1)
            node_name = args.node[1]
            node_id = args.node[2]
            remove_node(node_name, node_id)
            
        elif command == "show":
            if len(args.node) < 3:
                print("Usage: --node show <node_name> <node_id>")
                sys.exit(1)
            node_name = args.node[1]
            node_id = args.node[2]
            output = args.node[3] if len(args.node) > 3 else 0
            show_node(node_name, node_id, output=output)
            
        elif command == "list" or command == "ls":
            list_nodes()
            
        else:
            print(f"Unknown node command: {command}")
            sys.exit(1)
            
    elif args.user:
        args = user_parser.parse_args(args.user)
        args.func(args)
        
    elif args.project:
        args = project_parser.parse_args(args.project)
        args.func(args)
        
    elif args.general:
        args = general_parser.parse_args(args.general)
        args.func(args)
    else:
        parser.print_help()
    sys.exit(0)

def parse_key_value_args(arg_list):
    args_dict = {}
    for arg in arg_list:
        if '=' in arg:
            key, val = arg.split('=', 1)
            args_dict[key] = val
        else:
            print(f"[WARN] Argument '{arg}' ignored (not in key=value format)")
    return args_dict


if __name__ == "__main__":
    main()