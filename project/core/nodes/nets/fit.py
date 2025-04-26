from .utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR


class Fit(BaseNode):
    """Orchestrates the fitting process."""
    def __init__(self, X, y, batch_size, epochs,  model=None, model_path=None, project_id=None, *args, **kwargs):
        self.model = model
        self.model_path = model_path
        self.batch_size = batch_size
        self.epochs = epochs
        self.X, self.y = NodeDataExtractor()(X, y)
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.payload = self._fit()

    def _fit(self):
        if isinstance(self.model, (dict, int)):
            return self._fit_from_dict()
        elif isinstance(rf"{self.model_path}", str):
            return self._fit_from_path()
        else:
            raise ValueError("Invalid model or path provided.")

    def _fit_from_dict(self):
        try:
            model = NodeDataExtractor()(self.model)
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by ID: {e}")

    def _fit_from_path(self):
        try:
            model = NodeDataExtractor()(self.model_path)
            return self._fit_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by path: {e}")
    

    def _fit_handler(self, model):
        try:
            model.fit(self.X, self.y, batch_size=self.batch_size, epochs=self.epochs)

            payload = PayloadBuilder.build_payload("NN fitted", model, "nn_fitter", node_type="fitter", task="fit_model",
                                                       params={"batch_size": self.batch_size, "epochs": self.epochs},
                                                       uid=self.uid)
            if self.project_id:
                payload['project_id'] = self.project_id

            project_path = f"{self.project_id}\\" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}\{project_path}nets")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            raise ValueError(f"Error fitting model: {e}")
