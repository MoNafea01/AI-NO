# Data loading nodes
# backend/core/nodes/dataLoader.py
import os
from .utils import NodeSaver, NodeNameHandler, NodeLoader, DATASETS as datasets


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
            payload = {
                "message": f"Pre-defined Data loaded: {self.dataset_name}",
                "params":{},
                "node_data": data,
                "node_name": "data_loader",
                "node_id": id(self),
            }
            return payload
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
                X,y = data 

            elif self.dataset_path.endswith('.csv'):
                import pandas as pd
                data = pd.read_csv(self.dataset_path)
                if data.shape[1] == 1:
                    X = data.iloc[:, :-1].values
                    y = None
                else:
                    X = data.iloc[:, :-1].values
                    y = data.iloc[:, -1].values

            dataset_name, _ = NodeNameHandler.handle_name(self.dataset_path)
            payload = {
                "message": f"Custom data loaded: {dataset_name}",
                "node_data": (X, y),
                "node_name": "data_loader",
                "node_id": id(self),
                "params": {},
            }
            return payload
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
        self.payload = self.loader.load()
        self.X = self.payload['node_data'][0]
        self.y = self.payload['node_data'][1]

    def __str__(self):
        return str(self.payload)

    def __call__(self, *args):
        payload = self.payload.copy()
        for arg in args:
            if arg == '1':
                payload['node_data'] = self.X
            elif arg == '2':
                payload['node_data'] = self.y
        NodeSaver()(payload, path="core/nodes/saved/data")
        return payload
                

if __name__ == "__main__":
    # Example usage
    # loader = DataLoader(dataset_name='iris')
    # X, y = loader.load()

    # loader = DataLoader(dataset_name='diabetes')
    # X, y = loader('X'),loader('y')

    loader = DataLoader(dataset_name='custom', dataset_path=r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\project\core\data.csv")
    X, y = loader('X'),loader('y')
    print(f"Loaded data: {X}, {y}")
    

