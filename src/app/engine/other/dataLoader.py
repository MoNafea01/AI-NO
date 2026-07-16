import os

import pandas as pd

from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..configs.defaults import DATASETS as datasets
from ..repositories.execution import EnginePersistence
from ..utils import NodeNameHandler, PayloadBuilder, load_data


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

            if self.dataset_path.endswith(".pkl"):
                data = EnginePersistence.load_data(
                    self.dataset_path, project_id=self.project_id
                )
                X, y = data

            elif (
                self.dataset_path.endswith(".csv")
                or self.dataset_path.endswith(".xlsx")
                or self.dataset_path.endswith(".tsv")
            ):
                if self.dataset_path.endswith(".xlsx"):
                    data = pd.read_excel(self.dataset_path)
                else:
                    if self.dataset_path.endswith(".tsv"):
                        data = pd.read_csv(self.dataset_path, sep="\t")
                    else:
                        if self.dataset_path.endswith(".csv"):
                            data = pd.read_csv(self.dataset_path)

                X = data.iloc[:, :-1].values
                if data.shape[1] == 1:
                    y = None
                else:
                    y = data.iloc[:, -1].values

            elif not os.path.isfile(self.dataset_path):
                X, y, _ = load_data(self.dataset_path)

            else:
                return (
                    f"Unsupported file format: .{self.dataset_path.split('.')[-1]}",
                    None,
                )

            return X, y
        except Exception as e:
            return f"Error loading data: {e}", None


class UnSupportedDataLoader(BaseDataLoader):
    """Data loader for unsupported datasets."""
    def __init__(self, dataset_name):
        self.dataset_name = dataset_name

    def load(self):
        return f"Unsupported dataset: {self.dataset_name}", None


class DataLoaderFactory:
    """Factory class for creating data loaders."""
    @staticmethod
    def create(dataset_name=None, dataset_path=None, project_id=None):
        if dataset_path:
            return CustomDataLoader(dataset_path, project_id)
        elif dataset_name:
            return PredefinedDataLoader(dataset_name, project_id)
        else:
            return UnSupportedDataLoader(dataset_name)


class DataLoader(BaseNode):
    """Facade for loading data using different strategies.

    Stores port-keyed results: {"0:0": X, "0:1": y} for "X and y" output group.
    """

    def __init__(self, dataset_name=None, dataset_path=None, **kwargs):
        self.dataset_name = dataset_name
        self.dataset_path = dataset_path
        super().__init__(**kwargs)

    def execute(self):
        self.loader = DataLoaderFactory.create(
            self.dataset_name, self.dataset_path, self.project_id
        )

        X, y = self.loader.load()
        if isinstance(X, str):
            self.payload = X
            return self.payload

        self.payload = self._build_payload(self.dataset_name, self.dataset_path, X, y)
        return self.payload

    def _build_payload(self, dataset_name, dataset_path, X, y):
        try:
            if dataset_path:
                dataset_name, _ = NodeNameHandler.handle_name(dataset_path)

            port_data = {"0:0": X, "0:1": y}

            payload = PayloadBuilder.build_payload(
                f"data loaded: {dataset_name}",
                port_data,
                "data_loader",
                node_type="loader",
                task="load_data",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                location_x=self.location_x,
                location_y=self.location_y,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                params={"dataset_name": dataset_name, "dataset_path": dataset_path},
                displayed_name=self.displayed_name,
            )

            EnginePersistence.save_result(payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error building payload: {e}"
