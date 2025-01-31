# Data loading nodes
# backend/core/nodes/dataLoader.py
import os
import pandas as pd
from .utils import NodeSaver, NodeNameHandler, PayloadBuilder, NodeLoader, DATASETS as datasets


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
                data, _ = NodeLoader()(path=self.dataset_path)
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
    def __init__(self, dataset_name: str = None, dataset_path: str = None):
        self.loader = DataLoaderFactory.create(dataset_name, dataset_path)
        X, y = self.loader.load()
        if not dataset_name:
            dataset_name, _ = NodeNameHandler.handle_name(dataset_path)
        payloadX = PayloadBuilder.build_payload(f"Predefined data loaded: {dataset_name}: X", X, "data_loader", node_type="general")
        payloady = PayloadBuilder.build_payload(f"Predefined data loaded: {dataset_name}: y", y, "data_loader", node_type="general")
        NodeSaver()(payloadX, path="core/nodes/saved/data")
        NodeSaver()(payloady, path="core/nodes/saved/data")
        self.payload = payloadX, payloady

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        payload = self.payload
        for arg in args:
            if arg == '1':
                payload = self.payload[0]
            elif arg == '2':
                payload = self.payload[1]
        return payload
                

if __name__ == "__main__":
    dl_args = {
        "dataset_name": "iris",
    }
    dl = DataLoader(**dl_args)
    print(dl)
    

