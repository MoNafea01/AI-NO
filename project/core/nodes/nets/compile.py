from .utils import PayloadBuilder
from ...repositories import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR
from keras.api.models import Sequential

class CompileModel(BaseNode):
    """
    Compile layer for Keras models.
    """

    def __init__(self, loss, optimizer, metrics, nn_model = None, model_path = None , project_id=None, *args, **kwargs):
        self.loss = loss
        self.optimizer = optimizer
        self.metrics = metrics
        self.nn_model = nn_model
        self.nn_model_path = model_path
        self.project_id = project_id
        self.uid = kwargs.get('uid', None)
        self.input_ports = kwargs.get('input_ports', None)
        self.output_ports = kwargs.get('output_ports', None)
        self.displayed_name = kwargs.get('displayed_name', None)
        self.payload = self._compile()
    
    def _compile(self):
        if isinstance(self.nn_model, (dict, int, str)):
            return self._compile_from_dict(self.nn_model)
        
        elif self.nn_model_path and isinstance(self.nn_model_path, str):
            return self._compile_from_path(self.nn_model_path)
        else:
            return "Invalid model or path provided."

    def _compile_from_dict(self, model_id):
        try:
            model = NodeDataExtractor()(model_id, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load nn model. Please check the provided ID."
            return self._compile_handler(model)
        except Exception as e:
            return f"Error Compiling model by ID: {e}"

    def _compile_from_path(self, nn_model_path):
        try:
            model = NodeDataExtractor()(path=nn_model_path, project_id=self.project_id)
            if isinstance(model, str):
                return "Failed to load nn model. Please check the provided path."
            return self._compile_handler(model)
        except Exception as e:
            return f"Error Compiling model from path: {e}"

    def _compile_handler(self, model:Sequential):
        try:
            if not all([self.loss, self.optimizer, self.metrics]):
                return "Loss, optimizer, and metrics must be provided for compilation."
            
            model.compile(loss=self.loss, optimizer=self.optimizer, metrics=self.metrics)
            payload = PayloadBuilder.build_payload("Model Compiled", model, "model_compiler", task="compile_model", node_type="compiler",
                                                       params={"loss": self.loss, "optimizer": self.optimizer, "metrics": self.metrics},
                                                       uid=self.uid, output_ports=self.output_ports, input_ports=self.input_ports, project_id=self.project_id,
                                                       displayed_name=self.displayed_name)

            project_path = f"{self.project_id}/" if self.project_id else ""
            NodeSaver()(payload, path=rf"{SAVING_DIR}/{project_path}nets")
            payload.pop("node_data", None)
            return payload
        
        except Exception as e:
            return f"Error creating compile layer payload: {e}"
