# Data loading nodes
# backend/core/nodes/dataLoader.py
import os
import pandas as pd
from ..utils import NodeNameHandler, PayloadBuilder
from ..configs.datasets import DATASETS as datasets
from ...repositories.node_repository import NodeSaver, NodeDataExtractor


class BaseDataLoader:
    """Abstract base class for all data loaders."""
    def load(self):
        raise NotImplementedError("Subclasses must implement the load method.")


class PredefinedDataLoader(BaseDataLoader):
    """Loads predefined datasets like iris or diabetes."""
    def __init__(self, dataset_name):
        self.dataset_name = dataset_name

    def load(self):
        try:
            if self.dataset_name not in datasets.keys():
                raise ValueError(f"Unsupported dataset name: {self.dataset_name}")
            data = datasets[self.dataset_name](return_X_y=True)
            X, y = data
            return X, y
        except Exception as e:
            raise ValueError(f"Error loading data: {e}")


class CustomDataLoader:
    def __init__(self, dataset_path):
        self.dataset_path = dataset_path
    def load(self):
        try:
            if not os.path.exists(self.dataset_path):
                raise FileNotFoundError(f"dataset not found: {self.dataset_path}")
            
            if self.dataset_path.endswith('.pkl'):
                data = NodeDataExtractor()(self.dataset_path)
                X, y = data
                
            elif self.dataset_path.endswith('.csv'):
                
                data = pd.read_csv(self.dataset_path)
                X = data.iloc[:, :-1].values
                if data.shape[1] == 1:
                    y = None
                else:
                    y = data.iloc[:, -1].values

            return X, y
        except Exception as e:
            raise ValueError(f"Error loading data: {e}")


class DataLoaderFactory:
    """Factory class for creating data loaders."""
    @staticmethod
    def create(dataset_name=None, dataset_path=None):
        if dataset_name:
            return PredefinedDataLoader(dataset_name)
        elif dataset_path:
            return CustomDataLoader(dataset_path)
        else:
            raise ValueError("Either dataset_name or dataset_path must be provided.")


class DataLoader:
    """Facade for loading data using different strategies."""
    def __init__(self, dataset_name: str = None, dataset_path: str = None, project_id: int = None):
        self.loader = DataLoaderFactory.create(dataset_name, dataset_path)
        X, y = self.loader.load()
        self.project_id = project_id
        self.payload = self.build_payload(dataset_name, dataset_path, X, y)
        
    
    def build_payload(self, dataset_name, dataset_path, X, y):
        if not dataset_name:
            dataset_name, _ = NodeNameHandler.handle_name(dataset_path)

        
        payload = []
        payload.append(PayloadBuilder.build_payload(f"data loaded: {dataset_name}", (X, y), "data_loader", node_type="loader", task="load_data", project_id=self.project_id))
        names = ["X", "y"]

        for i in range(1, 3):
            payload.append(PayloadBuilder.build_payload(f"data loaded: {dataset_name}: {names[i-1]}", [X, y][i-1], "data_loader", node_type="loader", task="load_data", project_id=self.project_id))
        
        payload[0]['children'] = [ payload[1]["node_id"], payload[2]["node_id"] ]
        for i in range(3):
            NodeSaver()(payload[i], path="core/nodes/saved/data")
            payload[i].pop("node_data", None)
        
        return payload

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args, **kwargs):
        payload = self.payload[0]
        for arg in args:
            if arg == '1':
                payload = self.payload[1]
            elif arg == '2':
                payload = self.payload[2]

        return_serialized = kwargs.get("return_serialized", False)
        if return_serialized:
            node_data = NodeDataExtractor(return_serialized=True)(payload)
            payload.update({"node_data": node_data})
        return payload
