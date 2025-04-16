from .utils import PayloadBuilder
from ...repositories.node_repository import NodeSaver, NodeDataExtractor
from ..base_node import BaseNode, SAVING_DIR
from keras.api.models import Sequential

class CompileModel(BaseNode):
    """
    Compile layer for Keras models.
    """

    def __init__(self, loss, optimizer, metrics, model = None, model_path = None , project_id=None, *args, **kwargs):
        self.loss = loss
        self.optimizer = optimizer
        self.metrics = metrics
        self.model = model
        self.model_path = model_path
        self.project_id = project_id
        self.payload = self._compile()
    
    def _compile(self):
        if isinstance(self.model, (dict, int)):
            return self._compile_from_dict()
        elif isinstance(rf"{self.model_path}", str):
            return self._compile_from_path()
        else:
            raise ValueError("Invalid model or path provided.")

    def _compile_from_dict(self):
        try:
            model = NodeDataExtractor()(self.model)
            return self._compile_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model by ID: {e}")

    def _compile_from_path(self):
        try:
            model = NodeDataExtractor()(path=self.model_path)
            return self._compile_handler(model)
        except Exception as e:
            raise ValueError(f"Error fitting model from path: {e}")

    def _compile_handler(self, model:Sequential):
        try:
            if self.loss and self.optimizer:
                model.compile(loss=self.loss, optimizer=self.optimizer, metrics=self.metrics)
            else:
                raise ValueError("Loss, optimizer, and metrics must be provided for compilation.")

            payload = PayloadBuilder.build_payload("Model Compiled", model, "model_compiler", task="compile_model", node_type="compiler",
                                                       params={"loss": self.loss, "optimizer": self.optimizer, "metrics": self.metrics})

            if self.project_id:
                payload['project_id'] = self.project_id

            NodeSaver()(payload, path=rf"{SAVING_DIR}\nets")
            payload.pop("node_data", None)
            return payload
        
        except Exception as e:
            raise ValueError(f"Error creating compile layer payload: {e}")
