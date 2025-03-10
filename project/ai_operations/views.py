from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.views import APIView, Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser

from core.nodes.other.dataLoader import DataLoader
from core.nodes.other.train_test_split import TrainTestSplit
from core.nodes.other.custom import Joiner, Splitter

from core.nodes.model.model import Model
from core.nodes.model.fit import Fit as FitModel
from core.nodes.model.predict import Predict
from core.nodes.model.evaluator import Evaluator

from core.nodes.preprocessing.preprocessor import Preprocessor
from core.nodes.preprocessing.fit import Fit as FitPreprocessor
from core.nodes.preprocessing.transform import Transform
from core.nodes.preprocessing.fit_transform import FitTransform

from core.nodes.nets.input_layer import InputLayer
from core.nodes.nets.dnn_layers import DenseLayer, DropoutLayer
from core.nodes.nets.cnn_layers import Conv2DLayer, MaxPool2DLayer
from core.nodes.nets.flatten_layer import FlattenLayer
from core.nodes.nets.sequential import SequentialNet


from core.repositories.node_repository import (
    NodeLoader, NodeSaver, 
    NodeDeleter, NodeUpdater, ClearAllNodes)

from .serializers import *
import pandas as pd
import json

MODELS_TASKS = ["regression", "classification", "fit_model", "predict", "evaluate"]
PREPROCESSORS = ["preprocessing", "fit_preprocessor", "transform", "fit_transform"]
LAYERS = ["neural_network"]
DATA_NODES = ["load_data", "split","join"]

class NodeQueryMixin:
    """
    A mixin to handle 'get' requests for any ViewSet.
    It extracts 'node_id' from request parameters and uses NodeLoader.
    """
    def get(self, request, *args, **kwargs):
        try:
            node_id = request.query_params.get('node_id')
            channel = request.query_params.get('output')
            if channel in ['1', '2']:
                parent_node = NodeLoader()(node_id=node_id)
                if parent_node:
                    children = parent_node.get("children")
                    child_id = list(children.values())
                    if len(child_id) > 0:
                        node_id = str(child_id[0]) if channel == '1' else str(child_id[1]) if channel == '2' else node_id

            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            payload = NodeLoader(return_serialized=return_serialized)(node_id=node_id)
            if not return_serialized:
                payload.pop('node_data', None)
            return Response(payload, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        try:
            node_id = request.query_params.get('node_id')
            node = NodeLoader()(node_id=node_id)
            node_name = node.get('node_name')
            is_multi_channel = node_name in ["data_loader", "train_test_split", "splitter"]
            is_special_case = node_name in ['fitter_transformer']
            if not node_id:
                return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
            try:
                success, message = NodeDeleter(is_special_case, is_multi_channel)(node_id)
                if success:
                    return Response({"message": f"Node {node_id} deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
                else:
                    return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
            
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class BaseNodeAPIView(APIView, NodeQueryMixin):
    def get_serializer_class(self):
        """Override this method to return the appropriate serializer class."""
        raise NotImplementedError

    def get_processor(self, validated_data):
        """Override this method to return the processing class instance."""
        raise NotImplementedError

    def post(self, request):
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            processor = self.get_processor(serializer.validated_data)
            output_channel = request.query_params.get('output', None)
            
            return_serialized = request.query_params.get('return_serialized', '0') == '1'
            response_data = processor(output_channel, return_serialized=return_serialized)
            return Response(response_data, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            processor = self.get_processor(serializer.validated_data)
            node_id = request.query_params.get('node_id', None)
            return_serialized = request.query_params.get('return_serialized', '0') == '1'
            success, message = NodeUpdater(return_serialized)(node_id, processor())

            if not return_serialized:
                message.pop("node_data", None)
            
            status_code = status.HTTP_200_OK if success else status.HTTP_400_BAD_REQUEST
            return Response(message if success else {"error": message}, status=status_code)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DataLoaderAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return DataLoaderSerializer

    def get_processor(self, validated_data):
        return DataLoader(
            dataset_name=validated_data.get('dataset_name'),
            dataset_path=validated_data.get('dataset_path')
        )


class TrainTestSplitAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return TrainTestSplitSerializer

    def get_processor(self, validated_data):
        return TrainTestSplit(
            data=validated_data.get('data'),
            params=validated_data.get('params')
        )


class SplitterAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return SplitterSerializer

    def get_processor(self, validated_data):
        return Splitter(
            data=validated_data.get('data')
        )


class JoinerAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return JoinerSerializer

    def get_processor(self, validated_data):
        return Joiner(
            data_1=validated_data.get('data_1'), 
            data_2=validated_data.get('data_2')
        )


class CreateModelView(BaseNodeAPIView):
    def get_serializer_class(self):
        return ModelSerializer

    def get_processor(self, validated_data):
        return Model(
            model_name=validated_data.get('model_name'),
            model_type=validated_data.get('model_type'),
            task=validated_data.get('task'),
            params=validated_data.get('params'),
            model_path=validated_data.get('model_path'),
        )


class FitModelAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return FitModelSerializer

    def get_processor(self, validated_data):
        return FitModel(
            X=validated_data.get('X'),
            y=validated_data.get('y'),
            model=validated_data.get('model'),
            model_path=validated_data.get('model_path'),
        )


class PredictAPIView(BaseNodeAPIView):
    """API view to handle predictions using a trained model."""

    def get_serializer_class(self):
        return PredictSerializer

    def get_processor(self, validated_data):
        return Predict(
            X=validated_data.get('X'),
            model=validated_data.get('model'),
            model_path=validated_data.get('model_path'),
        )


class EvaluatorAPIView(BaseNodeAPIView):
    """API view to evaluate model predictions based on a given metric."""

    def get_serializer_class(self):
        return EvaluatorSerializer

    def get_processor(self, validated_data):
        return Evaluator(
            metric=validated_data.get('metric'),
            y_true=validated_data.get('y_true'),
            y_pred=validated_data.get('y_pred'),
        )


class PreprocessorAPIView(BaseNodeAPIView):
    """API view to create and update a Preprocessor instance."""

    def get_serializer_class(self):
        return PreprocessorSerializer

    def get_processor(self, validated_data):
        return Preprocessor(
            preprocessor_name=validated_data.get('preprocessor_name'),
            preprocessor_type=validated_data.get('preprocessor_type'),
            params=validated_data.get('params'),
            preprocessor_path=validated_data.get('preprocessor_path'),
        )


class FitPreprocessorAPIView(BaseNodeAPIView):
    """API view for fitting a preprocessor on the given data."""

    def get_serializer_class(self):
        return FitPreprocessorSerializer

    def get_processor(self, validated_data):
        return FitPreprocessor(
            data=validated_data.get('data'),
            preprocessor=validated_data.get('preprocessor'),
            preprocessor_path=validated_data.get('preprocessor_path'),
        )


class TransformAPIView(BaseNodeAPIView):
    """API view for transforming data using a given preprocessor."""

    def get_serializer_class(self):
        return TransformSerializer

    def get_processor(self, validated_data):
        return Transform(
            data=validated_data.get('data'),
            preprocessor=validated_data.get('preprocessor'),
            preprocessor_path=validated_data.get('preprocessor_path'),
        )


class FitTransformAPIView(BaseNodeAPIView):
    """API view for fitting and transforming data using a given preprocessor."""

    def get_serializer_class(self):
        return FitTransformSerializer

    def get_processor(self, validated_data):
        return FitTransform(
            data=validated_data.get('data'),
            preprocessor=validated_data.get('preprocessor'),
            preprocessor_path=validated_data.get('preprocessor_path'),
        )


class InputAPIView(BaseNodeAPIView):
    """API view for handling input layers."""

    def get_serializer_class(self):
        return InputSerializer

    def get_processor(self, validated_data):
        return InputLayer(
            shape=validated_data.get("shape"),
            name=validated_data.get("name"),
            path=validated_data.get("path"),
        )


class Conv2DAPIView(BaseNodeAPIView):
    """API view for handling Conv2D layers."""

    def get_serializer_class(self):
        return Conv2DSerializer

    def get_processor(self, validated_data):
        return Conv2DLayer(
            prev_node=validated_data.get("prev_node"),
            filters=validated_data.get("filters"),
            kernel_size=validated_data.get("kernel_size"),
            strides=validated_data.get("strides"),
            padding=validated_data.get("padding"),
            activation=validated_data.get("activation"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
        )


class MaxPool2DAPIView(BaseNodeAPIView):
    """API view for handling MaxPool2D layers."""

    def get_serializer_class(self):
        return MaxPool2DSerializer

    def get_processor(self, validated_data):
        return MaxPool2DLayer(
            prev_node=validated_data.get("prev_node"),
            pool_size=validated_data.get("pool_size"),
            strides=validated_data.get("strides"),
            padding=validated_data.get("padding"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
        )


class FlattenAPIView(BaseNodeAPIView):
    """API view for handling Flatten layers."""

    def get_serializer_class(self):
        return FlattenSerializer

    def get_processor(self, validated_data):
        return FlattenLayer(
            prev_node=validated_data.get("prev_node"),
            name=validated_data.get("name"),
            path=validated_data.get("path"),
        )


class DenseAPIView(BaseNodeAPIView):
    """API view for handling dense layers."""

    def get_serializer_class(self):
        return DenseSerializer

    def get_processor(self, validated_data):
        return DenseLayer(
            prev_node=validated_data.get("prev_node"),
            units=validated_data.get("units"),
            activation=validated_data.get("activation"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
        )


class DropoutAPIView(BaseNodeAPIView):
    """API view for handling Dropout layers."""

    def get_serializer_class(self):
        return DropoutSerializer

    def get_processor(self, validated_data):
        return DropoutLayer(
            prev_node=validated_data.get("prev_node"),
            rate=validated_data.get("rate"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
        )


class SequentialAPIView(BaseNodeAPIView):
    """API view for handling Sequential models."""

    def get_serializer_class(self):
        return SequentialSerializer

    def get_processor(self, validated_data):
        return SequentialNet(
            layer=validated_data.get("layer"),
            name=validated_data.get("name"),
            path=validated_data.get("path"),
        )


class NodeLoaderAPIView(APIView, NodeQueryMixin):
    def get_folder_by_task(self, task):
        folder = "models" if task in MODELS_TASKS else (
            "preprocessors" if task in PREPROCESSORS else (
                "nn" if task in LAYERS else (
                    "data" if task in DATA_NODES else "other")))
        return folder

    def get_serialized_payload(self, node_id, path, return_serialized):
        """Loads a node, saves it, and optionally serializes it."""
        loader = NodeLoader(from_db=False)
        l = NodeLoader()
        payload = loader(node_id=node_id, path=path)
        node = l(node_id=node_id, path=path)
        payload.update({"node_name":node.get("node_name")})
        folder = self.get_folder_by_task(node.get('task'))
        NodeSaver()(payload, path=f'core/nodes/saved/{folder}')

        # Reload the node with serialization settings
        payload = NodeLoader(return_serialized=return_serialized)(node_id=payload.get("node_id"))

        if not return_serialized:
            payload.pop("node_data", None)
        return payload
    
    def post(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            try:
                node_id = serializer.validated_data.get('node_id')
                path = serializer.validated_data.get('node_path')
                return_serialized = request.query_params.get("return_serialized") == "1"
                
                payload = self.get_serialized_payload(node_id, path, return_serialized)
                return Response(payload, status=status.HTTP_200_OK)
            
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            node_id = serializer.validated_data.get('node_id')
            path = serializer.validated_data.get('node_path')
            return_serialized = request.query_params.get("return_serialized") == "1"
            
            payload = self.get_serialized_payload(node_id, path, return_serialized=return_serialized)
            
            node_id = request.query_params.get('node_id', None)
            success, message = NodeUpdater(return_serialized)(node_id, payload)
            if not return_serialized:
                    message.pop("node_data", None)
                    
            if success:
                return Response({"message": message}, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        

class NodeSaveAPIView(APIView, NodeQueryMixin):
    def process_node_save(self, request):
        """Handles node saving logic for both POST and PUT requests."""
        payload = request.data.get("node")
        path = request.data.get("node_path")  # Optional path parameter
        return_serialized = request.query_params.get("return_serialized") == "1"
        try:
            saver = NodeSaver()
            node_data = NodeLoader()(node_id=payload.get("node_id")).get("node_data")
            payload["node_data"] = node_data
            payload["node_id"] = id(saver)

            saved_response = saver(payload, path=path)
            response = saver(saved_response)

            if return_serialized:
                node_data = NodeLoader(return_serialized=True)(node_id=response.get("node_id")).get("node_data")
                response["node_data"] = node_data

            return Response(response, status=status.HTTP_200_OK)
        except ValueError as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"error": f"Internal error: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def post(self, request):
        serializer = NodeSaverSerializer(data=request.data)
        if serializer.is_valid():
            return self.process_node_save(request)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = NodeSaverSerializer(data=request.data)
        if serializer.is_valid():
            response = self.process_node_save(request)
            response_data = response.data
            node_id = request.query_params.get("node_id")
            return_serialized = request.query_params.get("return_serialized") == "1"

            success, message = NodeUpdater(return_serialized)(node_id, response_data)

            if return_serialized:
                message["node_data"] = NodeLoader()(message.get("node_id"), return_serialized=True).get("node_data")

            if success:
                return Response(message, status=status.HTTP_200_OK)
            return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ComponentAPIViewSet(viewsets.ModelViewSet):
    queryset = Component.objects.all()
    serializer_class = ComponentSerializer


class ClearNodesAPIView(APIView):
    def delete(self, request):
        try:
            response = ClearAllNodes()()
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ClearComponentsAPIView(APIView):
    def delete(self, request):
        try:
            response = ClearAllNodes()('components')
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ExcelUploadAPIView(APIView):
    parser_classes = [MultiPartParser]
    
    def post(self, request, format=None):
        if 'file' not in request.FILES:
            return Response({'error': 'No file uploaded'}, status=status.HTTP_400_BAD_REQUEST)
        
        file = request.FILES['file']
        try:
            df = pd.read_excel(file, engine='openpyxl')
            df = df.replace({r'\bTRUE\b': 'true', r'\bFALSE\b': 'false'}, regex=True)
            
            created_count = 0
            skipped_count = 0
            errors = []

            def parse_json_like(value):
                try:
                    return json.loads(value.replace("'", '"'))  # Handle single quotes
                except:
                    return None
            # Convert string representations to actual Python objects
            for col in ['params', 'input_channels', 'output_channels']:
                df[col] = df[col].apply(lambda x: 
                                        parse_json_like(x) if pd.notnull(x) else None
                                        )
            
            # Create components in database
            for index, row in df.iterrows():
                try:
                    # Clean up parameter names
                    node_name = str(row['node_name']).strip()
                    if Component.objects.filter(node_name=node_name).exists():
                        skipped_count += 1
                        continue
                    row_data = row.to_dict()
                    if row_data.get('params'):
                        for param in row_data['params']:
                            param['name'] = param['name'].strip()
                    
                    serializer = ComponentSerializer(data=row_data)
                    if serializer.is_valid():
                        serializer.save()
                        created_count += 1
                    else:
                        errors.append({
                            'row': index + 2,  # +2 for 0-index and header row
                            'errors': serializer.errors,
                            'data': row_data
                        })
                except Exception as e:
                        errors.append({
                            'row': index + 2,
                            'error': str(e),
                            'data': row.to_dict()
                        })
            response = {
            'created': created_count,
            'skipped': skipped_count,
            'errors': errors
            }    
            return Response(response, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class NodeAPIViewSet(viewsets.ModelViewSet):
    queryset = Node.objects.all()
    serializer_class = NodeSerializer

    def create(self, request, *args, **kwargs):
        """Handle bulk creation of nodes"""
        if isinstance(request.data, list):
            serializer = self.get_serializer(data=request.data, many=True)
        else:
            serializer = self.get_serializer(data=request.data)

        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
