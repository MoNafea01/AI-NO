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
        self.X, self.y = NodeDataExtractor()(X, y, project_id=project_id)
        err = None
        if any(isinstance(i, str) for i in [self.X, self.y]):
            err = "Failed to load Nodes (X, y) at least one of them. Please check the provided IDs."
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self._fit(err)
        

    def _fit(self, err=None):
        if err:
            return err
        if isinstance(self.model, (dict, int, str)):
            return self._fit_from_dict()
        
        elif self.model_path and isinstance(self.model_path, str):
            return self._fit_from_path()
        else:
            return "Invalid nn model or path provided."

    def _fit_from_dict(self):
        try:
            model = NodeDataExtractor()(self.model, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load nn model. Please check the provided ID."
            return self._fit_handler(model)
        except Exception as e:
            return f"Error fitting nn model by ID: {e}"

    def _fit_from_path(self):
        try:
            model = NodeDataExtractor()(self.model_path, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load nn model. Please check the provided path."
            return self._fit_handler(model)
        except Exception as e:
            return f"Error fitting nn model by path: {e}"
    

    def _fit_handler(self, model):
        try:
            model.fit(self.X, self.y, batch_size=self.batch_size, epochs=self.epochs)
            if isinstance(model, str):
                return f"Model fitting failed. {model}"


            payload = PayloadBuilder.build_payload("NN fitted", model, "nn_fitter", node_type="fitter", task="fit_model",
                                                       params={"batch_size": self.batch_size, "epochs": self.epochs},
                                                       uid=self.uid, output_ports=self.output_ports,input_ports=self.input_ports, project_id=self.project_id,
                                                       displayed_name=self.displayed_name)

            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, rf"{SAVING_DIR}/{project_path}nets")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error creating nn fitter payload: {e}"
