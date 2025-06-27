from ..utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor, NodeLoader
from ..base_node import BaseNode, SAVING_DIR
import os
from django.conf import settings
import pandas as pd
import joblib


base_dir = settings.BASE_DIR if hasattr(settings, 'BASE_DIR') else os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../../'))
schema_dir = os.path.join(base_dir, 'core', 'schema.xlsx')
blueprint_dir = os.path.join(base_dir, 'core', 'blueprint')
class Joiner(BaseNode):
    """
    This Class is responsible for joining two datasets.\n
    to get the joined data, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, data_1, data_2, project_id=None, *args, **kwargs):
        self.data_1, self.data_2 = NodeDataExtractor()(data_1, data_2, project_id=project_id)
        err = None
        if any(isinstance(i, str) for i in [self.data_1, self.data_2]):
            err = "Failed to load Nodes (data_1, data_2) at least one of them. Please check the provided IDs."
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.join(err)
    
    def join(self, err = None):
        if err:
            return err
        try:
            joined_data = (self.data_1, self.data_2)
            payload = PayloadBuilder.build_payload("joined_data", joined_data, "joiner", node_type="custom", task="join", project_id=self.project_id,
                                                   uid=self.uid, input_ports=self.input_ports, output_ports=self.output_ports, displayed_name=self.displayed_name,
                                                   location_x=self.location_x, location_y=self.location_y)
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}other")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error joining data: {e}"


class Splitter:
    """
    This Class is responsible for splitting the data into two parts.    
    to get the first part of the data, call the instance with 'out1' as an argument     
    to get the second part of the data, call the instance with 'out2' as an argument    
    it also accept a dictionary as an argument  
    Note that the dictionary must have a key named "data" that has a list of two elements   
    """
    def __init__(self, data, project_id=None, *args, **kwargs):
        self.project_id = project_id
        self.data = NodeDataExtractor()(data, project_id=project_id)
        err = None
        if isinstance(self.data, str):
            err = "Failed to load data. Please check the provided ID."
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.split(err)

    def split(self, err=None):
        if err:
            return err
        try:
            out1, out2 = self.data

            payload = []
            payload.append(PayloadBuilder.build_payload("data", (out1, out2), "splitter", node_type="custom", task="split", project_id=self.project_id, uid=self.uid,
                                                        input_ports=self.input_ports, output_ports=self.output_ports,
                                                        displayed_name=self.displayed_name, location_x=self.location_x, location_y=self.location_y))
            
            for i in range(1, 3):
                payload.append(PayloadBuilder.build_payload(f"data_{i}", [out1, out2][i-1], "splitter", node_type="custom", task="split", project_id=self.project_id, uid=self.uid,
                                                            parent=[payload[0]['node_id']]))
            
            payload[0]['children'] = [payload[1]["node_id"], payload[2]["node_id"]]
            for i in range(3):
                project_path = f"{self.project_id}/" if self.project_id else ""
                NodeSaver()(payload[i], rf"{SAVING_DIR}/{project_path}other")
                payload[i].pop("node_data", None)
            
            return payload
        except Exception as e:
            return f"Error splitting data: {e}"

    def __str__(self):
        return f"data: {self.payload}"
    
    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
            elif arg == '2':
                payload = self.payload[2]
                
        if isinstance(self.payload, str):
            payload = self.payload
        
        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload, project_id=self.project_id)
            payload.update({"node_data": node_data})
        return payload



class NodeTemplateSaver(BaseNode):
    """
    This Class is responsible for saving the node template.\n
    to get the saved template, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, node, name, description, project_id=None, *args, **kwargs):
        success, self.node = NodeLoader()(node, project_id=project_id)
        err = None
        if not success:
            err = "Failed to load node. Please check the provided ID."

        self.chosen_name = name
        self.description = description
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.save_template(err)

    def save_template(self, err=None):
        if err:
            return err
        
        try:
            schema = pd.read_excel(schema_dir, sheet_name="Sheet1")
            
            node_name = self.chosen_name.replace(" ", "_").lower()
            last_uid = schema['uid'].max() + 1
            while True:
                if node_name in schema['node_name'].values:
                    node_name = f"{node_name}_{last_uid}"
                else:
                    break
            params = self.make_node(schema, node_name, self.chosen_name, last_uid, self.description, self.node.get('params'))
            node_content = NodeDataExtractor()(self.node.get('node_id'), project_id=self.project_id)
            payload = PayloadBuilder.build_payload("node", node_content, node_name, node_type="custom", task="save_template", project_id=self.project_id,
                                                   uid=self.uid, input_ports=self.input_ports, output_ports=self.output_ports, displayed_name=self.displayed_name, 
                                                   params=params, location_x=self.location_x, location_y=self.location_y)
            
            NodeSaver()(payload, rf"{blueprint_dir}")
            payload.pop("node_data", None)
            return payload 
        except Exception as e:
            return f"Error saving node template: {e}"
    
    def make_node(self, schema, node_name, displayed_name, last_uid, description, params):
        category = "Custom"
        idx = 6

        node_type = "custom"
        task = "template"

        input_channels = None
        output_channels = ["node"]

        api_call = f"template/"
        new_node = {
            'uid': last_uid,
            'displayed_name': displayed_name,
            'description': description,
            'category': category,
            'idx': idx,
            'node_name': node_name,
            'node_type': node_type,
            'task': task,
            'params': params,
            'input_channels': input_channels,
            'output_channels': output_channels,
            'api_call': api_call
        }
        self.add_node_to_schema(new_node, schema)
        return params

    def add_node_to_schema(self, new_node, schema):
        schema = pd.concat([schema, pd.DataFrame([new_node])], ignore_index=True)
        schema.to_excel(schema_dir, index=False)
        print(f"Node {new_node['displayed_name']} added to schema.")


class NodeTemplateLoader(BaseNode):
    """
    This Class is responsible for loading the node template.\n
    to get the loaded template, call the instance with 'out' as an argument\n
    it also accept a dictionary as an argument\n
    Note that the dictionary must have a key named "data" that has a list of two elements\n
    """
    def __init__(self, template_id, project_id=None, *args, **kwargs):
        self.project_id = project_id
        err = None
        
        node_template_saver_uid = 65
        self.uid = node_template_saver_uid + int(template_id)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.location_x = kwargs.get('location_x', None)
        self.location_y = kwargs.get('location_y', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.load_template(err)
    
    def load_template(self, err=None):
        if err:
            return err
        
        try:
            schema = pd.read_excel(schema_dir, sheet_name="Sheet1")
            node = schema[schema['uid'] == self.uid].iloc[0]
            node_name = node['node_name']
            files_names = os.listdir(blueprint_dir)

            node_path = None
            for file_name in files_names:
                if file_name.startswith(node_name):
                    node_path = os.path.join(blueprint_dir, file_name)
                    break
            if not node_path:
                return f"Node template with name {node_name} not found."
            
            node_data = joblib.load(node_path)
            payload = PayloadBuilder.build_payload("node", node_data, "template", node_type="custom", task="load_template", project_id=self.project_id,
                                                   uid=self.uid, input_ports=self.input_ports, output_ports=self.output_ports, 
                                                   displayed_name=self.displayed_name, location_x=self.location_x, location_y=self.location_y)
            
            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}other")
            payload.pop("node_data", None)
            return payload

        except FileNotFoundError:
            return f"Node template with ID {self.uid} not found."
        except Exception as e:
            return f"Error loading node template: {e}"
        
    
        