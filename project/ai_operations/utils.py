from .models import Project, Node, Component
import numpy as np
from core.nodes.configs.const_ import MODELS_NAMES, DICT_NODES, PARENT_NODES, NODES_ORDERING
from rest_framework.views import Response
from rest_framework import status
from core.repositories import NodeLoader
import os, requests
from django.conf import settings
from cli.utils.mapper import create_mapper
from chatbot.res.defaults import create_data_mapping

def update_project_model_and_dataset(project_id, node):
    try:
        project = Project.objects.get(id=project_id)
        node_name = node.get('node_name')
        
        models_names = MODELS_NAMES.copy()
        models_names.append("sequential_model")
        models_names = models_names[3:] 
        
        if node_name in models_names:
            project.model = node_name
            project.save()
            return True, "Project model updated successfully."
        
        elif node_name == 'data_loader':
            message = node.get('message', '')
            
            if not message in ['X', 'y']:
                dataset = message.split(': ')[-1]
                
            project.dataset = dataset
            project.save()
            return True, "Project dataset updated successfully."
        else:
            return False, "Node does not correspond to a valid data loader or model."
        
    except Project.DoesNotExist:
        return False, "Project not found."


def delete_project_model_and_dataset(project_id, node):
    try:
        project = Project.objects.get(id=project_id)
        node_name = node.get('node_name')
        
        models_names = MODELS_NAMES.copy()
        models_names.append("sequential_model")
        models_names = models_names[3:] 
        
        if node_name in models_names:
            project.model = None
            project.save()
            return True, "Project model deleted successfully."
        
        elif node_name == 'data_loader':
            project.dataset = None
            project.save()
            return True, "Project dataset deleted successfully."
        else:
            return False, "Node does not correspond to a valid data loader or model."
        
    except Project.DoesNotExist:
        return False, "Project not found."


def get_input_ports(data, project_id):
        """Extract input ports from the validated data."""
        input_ports = []
        for key, node_id in data.items():
            if key in DICT_NODES:
                if isinstance(node_id, dict):
                    return False, Response(node_id, status=status.HTTP_400_BAD_REQUEST)
                success, loaded = NodeLoader(return_path=True)(node_id=node_id, project_id=project_id)
                if not success:
                    return False, Response({"error": loaded}, status=status.HTTP_400_BAD_REQUEST)
                if (len(loaded.get('parent')) == 1) and (loaded.get('node_name') not in PARENT_NODES):
                    out_name = loaded.get("message")
                    node_id = loaded.get("parent")[0]
                
                elif (len(loaded.get('parent')) == 0) or (loaded.get('node_name') in PARENT_NODES):
                    prev_node_uid = loaded.get("uid")
                    out_name = Component.objects.get(uid=prev_node_uid).output_channels[0] if Component.objects.filter(uid=prev_node_uid).exists() else None
                attr = {"name": key, "connectedNode": {"name": out_name, "nodeData": int(node_id)}}
                input_ports.append(attr)
        return True, input_ports


def get_output_ports(component_id):
        output_ports = []
        try:
            out_channels = Component.objects.get(uid=component_id).output_channels
            if out_channels is not None:
                for i in range(len(out_channels)):
                    output_ports.append({"name": out_channels[i]})
        except Component.DoesNotExist:
            return False, Response({"error": f"Component with uid {component_id} not found"}, status=status.HTTP_404_NOT_FOUND)
        return True, output_ports


def update_components():
        url = "http://127.0.0.1:8000/api/update_components/"
        path = str(os.path.join(settings.BASE_DIR, 'core', 'schema.xlsx')).replace("\\", r"\\")

        response = requests.request("PUT", url, json={"file_path": path})
        if response.status_code == 200:
            print("Schema updated successfully.")
            create_mapper(), create_data_mapping()

        return response
    

def get_optimum_location(node_name):
    loc_x, loc_y = 0.0, 0.0
    a, b, c, d, e, f = NODES_ORDERING.values()
    low, high = (1000, 1250) if node_name in a else (
        (1250, 1500) if node_name in b else (
            (1500, 1750) if node_name in c else (
                (1750, 2000) if node_name in d else (
                    (2000, 2250) if node_name in e else (
                        2250, 2500
                    )
                )
            )
        )
    )

    loc_x, loc_y = np.random.uniform(low=low, high=high, size=(2,)).tolist()
    
    return loc_x, loc_y

__all__ = [
    "update_project_model_and_dataset",
    "delete_project_model_and_dataset",
    "get_input_ports",
    "get_output_ports",
    "update_components",
    "get_optimum_location"
]