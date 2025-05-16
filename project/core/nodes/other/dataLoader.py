# Data loading nodes
# backend/core/nodes/dataLoader.py
import os
import pandas as pd
from ..utils import NodeNameHandler, PayloadBuilder, load_data
from ..configs.datasets import DATASETS as datasets
from ...repositories import NodeSaver, NodeDataExtractor
from core.nodes.configs.const_ import SAVING_DIR


class BaseDataLoader:
    """Abstract base class for all data loaders."""
    def load(self):
        raise NotImplementedError("Subclasses must implement the load method.")


class PredefinedDataLoader(BaseDataLoader):
    """Loads predefined datasets like iris or diabetes."""
    def __init__(self, dataset_name, project_id):
        self.dataset_name = dataset_name
        self.project_id = project_id

    def load(self):
        try:
            if self.dataset_name not in datasets.keys():
                return f"Unsupported dataset name: {self.dataset_name}", None
            data = datasets[self.dataset_name](return_X_y=True)
            X, y = data
            return X, y
        except Exception as e:
            return f"Error loading data: {e}", None


class CustomDataLoader:
    def __init__(self, dataset_path, project_id):
        self.dataset_path = dataset_path
        self.project_id = project_id
    def load(self):
        try:
            if not os.path.exists(self.dataset_path):
                return f"dataset not found: {self.dataset_path}", None
            
            if self.dataset_path.endswith('.pkl'):
                data = NodeDataExtractor()(self.dataset_path, project_id=self.project_id)
                X, y = data
                
            elif self.dataset_path.endswith('.csv') or self.dataset_path.endswith('.xlsx') or self.dataset_path.endswith('.tsv'):
                if self.dataset_path.endswith('.xlsx'):
                    data = pd.read_excel(self.dataset_path)
                else:
                    if self.dataset_path.endswith('.tsv'):
                        data = pd.read_csv(self.dataset_path, sep='\t')
                    else:
                        if self.dataset_path.endswith('.csv'):
                            data = pd.read_csv(self.dataset_path)

                X = data.iloc[:, :-1].values
                if data.shape[1] == 1:
                    y = None
                else:
                    y = data.iloc[:, -1].values

            elif not os.path.isfile(self.dataset_path):
                X, y, _ = load_data(self.dataset_path)

            else:
                return f"Unsupported file format: .{self.dataset_path.split('.')[-1]}", None

            return X, y
        except Exception as e:
            return f"Error loading data: {e}", None


class DataLoaderFactory:
    """Factory class for creating data loaders."""
    @staticmethod
    def create(dataset_name=None, dataset_path=None, project_id=None):
        if dataset_path:
            return CustomDataLoader(dataset_path, project_id)
        elif dataset_name:
            return PredefinedDataLoader(dataset_name, project_id)
        else:
            return "Either dataset_name or dataset_path must be provided."


class DataLoader:
    """Facade for loading data using different strategies."""
    def __init__(self, dataset_name: str = None, dataset_path: str = None, project_id: int = None, *args, **kwargs):
        self.loader = DataLoaderFactory.create(dataset_name, dataset_path, project_id)
        err = None
        if isinstance(self.loader, str):
            err = self.loader

        X, y = self.loader.load()
        if isinstance(X, str):
            err = X
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self.build_payload(dataset_name, dataset_path, X, y, err)
        
    
    def build_payload(self, dataset_name, dataset_path, X, y, err=None):
        try:
            if err:
                return err
            
            if dataset_path:
                dataset_name, _ = NodeNameHandler.handle_name(dataset_path)

            
            payload = []
            payload.append(PayloadBuilder.build_payload(f"data loaded: {dataset_name}", (X, y), "data_loader", node_type="loader", task="load_data", project_id=self.project_id,
                                                        uid=self.uid, location_x=400.0, location_y=400.0, input_ports=self.input_ports, output_ports=self.output_ports, params={"dataset_name": dataset_name, "dataset_path": dataset_path},
                                                        displayed_name=self.displayed_name))
            names = ["X", "y"]

            for i in range(1, 3):
                payload.append(PayloadBuilder.build_payload(f"{names[i-1]}", [X, y][i-1], "data_loader", node_type="loader", task="load_data", project_id=self.project_id,
                                                            uid=self.uid, parent=[payload[0]['node_id']]))
            
            payload[0]['children'] = [ payload[1]["node_id"], payload[2]["node_id"] ]
            for i in range(3):
                project_path = f"{self.project_id}/" if self.project_id else ""
                NodeSaver()(payload[i], path=rf"{SAVING_DIR}/{project_path}other")
                payload[i].pop("node_data", None)
            
            return payload
        except Exception as e:
            return f"Error building payload: {e}"

    def __str__(self):
        return str(self.payload)

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
