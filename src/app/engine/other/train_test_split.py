from sklearn.model_selection import train_test_split

from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..utils import PayloadBuilder


class TrainTestSplit(BaseNode):
    """Splits data into train/test sets.

    Stores port-keyed results: {"0:0": X_train, "0:1": X_test, "0:2": y_train, "0:3": y_test}.
    """

    def __init__(self, **kwargs):
        self.params = {"test_size": 0.2, "random_state": 42}
        super().__init__(**kwargs)
        if isinstance(kwargs.get("params"), dict):
            self.params.update(kwargs["params"])

    def execute(self):
        in_ports = self.in_ports or {}
        X_ref = in_ports.get("X")
        y_ref = in_ports.get("y")

        self.X = EnginePersistence.load_port(X_ref, self.project_id) if X_ref else None
        self.y = EnginePersistence.load_port(y_ref, self.project_id) if y_ref else None

        err = None
        if self.X is None and self.y is None:
            err = "Failed to load X and y. Please check the provided port refs."
        elif any(isinstance(i, str) for i in [self.X, self.y]):
            err = "Failed to load Nodes (X, y) at least one of them. Please check the provided IDs."

        self.payload = self.split(err)
        return self.payload

    def train_test_split(self, X=None, y=None, **params):
        try:
            if X is not None:
                X = train_test_split(X, **params)
            if y is not None:
                y = train_test_split(y, **params)
            return X, y
        except Exception as e:
            return f"Error splitting data: {e}", None

    def split(self, err=None):
        if err:
            return err
        try:
            out1, out2 = self.train_test_split(X=self.X, y=self.y, **self.params)
            if isinstance(out1, str) or isinstance(out2, str):
                return out1

            X_train, X_test = out1
            y_train, y_test = out2

            port_data = {
                "0:0": X_train,
                "0:1": X_test,
                "0:2": y_train,
                "0:3": y_test,
            }

            payload = PayloadBuilder.build_payload(
                "Data",
                port_data,
                "train_test_split",
                node_type="splitter",
                task="split",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                params=self.params,
                location_x=self.location_x,
                location_y=self.location_y,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
            )

            EnginePersistence.save_result(payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error splitting data (train test split): {e}"
