from ..utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR

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
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.join(err)
    
    def join(self, err = None):
        if err:
            return err
        try:
            joined_data = (self.data_1, self.data_2)
            payload = PayloadBuilder.build_payload("joined_data", joined_data, "joiner", node_type="custom", task="join", project_id=self.project_id,
                                                   uid=self.uid, input_ports=self.input_ports, output_ports=self.output_ports, displayed_name=self.displayed_name)
            
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
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.split(err)

    def split(self, err=None):
        if err:
            return err
        try:
            out1, out2 = self.data

            payload = []
            payload.append(PayloadBuilder.build_payload("data", (out1, out2), "splitter", node_type="custom", task="split", project_id=self.project_id, uid=self.uid,
                                                        location_x=self.get_location()[0], location_y=self.get_location()[1], input_ports=self.input_ports, output_ports=self.output_ports,
                                                        displayed_name=self.displayed_name))
            
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
    
    def get_location(self):
        in_ports = self.input_ports
        in_ports_names = [port.get("connectedNode").get("name") for port in in_ports]
        if "X" in in_ports_names:
            X_location, y_location = 500.0, 500.0
        elif "X_Split" in in_ports_names:
            X_location, y_location = 600.0, 500.0
        elif "y" in in_ports_names:
            X_location, y_location = 500.0, 300.0
        elif "y_Split" in in_ports_names:
            X_location, y_location = 600.0, 300.0
        else:
            X_location, y_location = 500.0, 400.0
        return X_location, y_location

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
