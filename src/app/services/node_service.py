"""Node execution service orchestration layer over the engine.

Maps node type keys to real engine classes and executes them.
"""

import logging
from typing import Any

logger = logging.getLogger(__name__)

# Engine imports (lazy via functions to keep startup fast)
from app.engine import (
    CompileModel,
    Conv2DLayer,
    DataLoader,
    DenseLayer,
    DropoutLayer,
    Evaluate,
    FitModel,
    FitNet,
    FitPreprocessor,
    FitTransform,
    FlattenLayer,
    InputLayer,
    Joiner,
    MaxPool2DLayer,
    Model,
    Predict,
    Preprocessor,
    SequentialNet,
    Splitter,
    TrainTestSplit,
    Transform,
)
from app.engine.other.custom import NodeTemplateLoader, NodeTemplateSaver

NODE_CLASS_REGISTRY = {
    "data_loader": DataLoader,
    "train_test_split": TrainTestSplit,
    "joiner": Joiner,
    "splitter": Splitter,
    "create_model": Model,
    "fit_model": FitModel,
    "predict": Predict,
    "evaluate": Evaluate,
    "create_preprocessor": Preprocessor,
    "fit_preprocessor": FitPreprocessor,
    "transform": Transform,
    "fit_transform": FitTransform,
    "create_input": InputLayer,
    "dense": DenseLayer,
    "conv2d": Conv2DLayer,
    "maxpool2d": MaxPool2DLayer,
    "flatten": FlattenLayer,
    "dropout": DropoutLayer,
    "sequential": SequentialNet,
    "compile": CompileModel,
    "fit_net": FitNet,
    "save_template": NodeTemplateSaver,
    "load_template": NodeTemplateLoader,
}


class NodeService:
    """Orchestrates node execution by delegating to the engine layer."""

    @staticmethod
    def execute_node(node_type: str, data: dict[str, Any]) -> dict[str, Any]:
        if node_type not in NODE_CLASS_REGISTRY:
            return {"message": f"Unknown node type: {node_type}", "error": True}
        try:
            cls = NODE_CLASS_REGISTRY[node_type]
            logger.info(f"Executing node '{node_type}' via {cls.__name__} with data {data}")
            if "params" in data and isinstance(data["params"], dict):
                logger.info(f"Node '{node_type}' params: {data['params']}")
                data.update(data.pop("params"))

            node_instance = cls(**data)
            result = node_instance.execute()
            if isinstance(result, str):
                return {"message": result, "error": True}
            return result
        except Exception as e:
            logger.exception(f"Error executing node '{node_type}'")
            return {"message": f"Error: {str(e)}", "error": True}

    @staticmethod
    async def async_execute_node(node_type: str, data: dict[str, Any]) -> dict[str, Any]:
        import asyncio

        return await asyncio.to_thread(NodeService.execute_node, node_type, data)
