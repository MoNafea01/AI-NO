# Data loading nodes
# backend/core/nodes/dataLoader.py
import pandas as pd
from sklearn.datasets import load_iris, load_diabetes
import os
from .utils import NodeSaver


class BaseDataLoader:
    """Abstract base class for all data loaders."""
    def load(self):
        raise NotImplementedError("Subclasses must implement the load method.")

class PredefinedDataLoader(BaseDataLoader):
    """Loads predefined datasets like iris or diabetes."""
    def __init__(self, data_type):
        self.data_type = data_type

    def load(self):
        datasets = {
            'iris': load_iris,
            'diabetes': load_diabetes
        }
        try:
            if self.data_type not in datasets:
                raise ValueError(f"Unsupported data type: {self.data_type}")
            data = datasets[self.data_type](return_X_y=True)
            payload = {
                "message": f"Pre-defined Data loaded: {self.data_type}",
                "params":{},
                "node_data": data,
                "node_name": "data_loader",
                "node_id": id(self),
            }
            NodeSaver.save(payload, path="core/nodes/saved/data")
            return payload
        except Exception as e:
            raise ValueError(f"Error loading data: {e}")

class CustomDataLoader(BaseDataLoader):
    """Loads custom datasets from a file."""
    def __init__(self, filepath):
        self.filepath = filepath

    def load(self):
        try:
            if not os.path.exists(self.filepath):
                raise FileNotFoundError(f"File not found: {self.filepath}")
            data = pd.read_csv(self.filepath)
            data_type = os.path.basename(self.filepath).split('.')[0]
            X = data.iloc[:, :-1].values
            y = data.iloc[:, -1].values
            payload = {
                "message": f"Custom data loaded: {data_type}",
                "node_data": (X, y),
                "node_name": "data_loader",
                "node_id": id(self),
                "params": {},
            }
            NodeSaver.save(payload, path="core/nodes/saved/data")
            return payload
        except Exception as e:
            raise ValueError(f"Error loading data: {e}")


class DataLoaderFactory:
    """Factory class for creating data loaders."""
    @staticmethod
    def create(data_type=None, filepath=None):
        if data_type:
            return PredefinedDataLoader(data_type)
        elif filepath:
            return CustomDataLoader(filepath)
        else:
            raise ValueError("Either data_type or filepath must be provided.")

class DataLoader:
    """Facade for loading data using different strategies."""
    def __init__(self, data_type: BaseDataLoader = None, filepath: str = None):
        self.loader = DataLoaderFactory.create(data_type, filepath)
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
        return payload
                

if __name__ == "__main__":
    # Example usage
    # loader = DataLoader(data_type='iris')
    # X, y = loader.load()

    # loader = DataLoader(data_type='diabetes')
    # X, y = loader('X'),loader('y')

    loader = DataLoader(data_type='custom', filepath=r"C:\Users\a1mme\OneDrive\Desktop\MO\test_grad\project\core\data.csv")
    X, y = loader('X'),loader('y')
    print(f"Loaded data: {X}, {y}")
    

