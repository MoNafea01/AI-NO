from __init__ import *
import json, datetime, tempfile, subprocess, random, pandas as pd

from rest_framework import status, viewsets
from rest_framework.views import APIView, Response
from rest_framework.parsers import MultiPartParser
from django.http import HttpResponse
from django.conf import settings
from .serializers import *

from core.nodes import *
from core.repositories import *
from core.nodes.configs.const_ import get_node_name_by_api_ref

from chatbot.app import sync_generate_cli
from cli.call_cli import call_script

class NodeQueryMixin:
    """
    A mixin to handle 'get' requests for any ViewSet.
    It extracts "node_id" from request parameters and uses NodeLoader.
    """
    def get_query_params(self, request):
        """Extracts query parameters from the request."""
        node_id = request.query_params.get("node_id")
        output = request.query_params.get('output', "0")
        return_serialized = request.query_params.get('return_serialized', '0') == '1'
        return_path = not return_serialized
        project_id = request.query_params.get('project_id')
        return_data = request.query_params.get('return_data', '0') == '1'
        return node_id, output, return_serialized, return_path, project_id, return_data
    
    def get(self, request, *args, **kwargs):
        try:
            # Extract query parameters
            node_id, output, return_serialized, return_path, project_id, return_data = self.get_query_params(request)

            if not node_id:
                return Response({"error": "'node_id' is required."}, status=status.HTTP_400_BAD_REQUEST)

            node = Node.objects.filter(node_id=node_id, project_id=project_id).first()
            if not node:
                return Response({"error": f"Node not found for project with id = {project_id}."}, status=status.HTTP_404_NOT_FOUND)
            
            if node.node_name not in DATA_NODES:
                return_data = False

            # get chain of nodes using "output" query_param, specific for layer nodes
            if output.isdigit() and int(output) > 0:
                depth = int(output)
                try:
                    success, current_node = NodeLoader(return_path=return_path, return_data=return_data)(node_id=node_id, project_id=project_id)
                    if success:
                        children = current_node.get("children", [])
                        if len(current_node.get("children")) > 1:
                            child_id = children[int(output) - 1] if len(children) >= int(output) else None
                            if isinstance(child_id, int):
                                success, current_node = NodeLoader(return_path=return_path)(node_id=str(child_id), project_id=project_id)
                                node_id = str(child_id)
                    else:
                        return Response({"error": current_node}, status=status.HTTP_400_BAD_REQUEST)
                except Exception as e:
                    return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
                
                # get node's children, for multi_channel nodes it has 2 children
                else:
                    for i in range(depth):
                        child = current_node.get("children", [])
                        if child:
                            child_id = child[0]
                            try:
                                success, current_node = NodeLoader(return_path=return_path)(node_id=str(child_id), project_id=project_id)
                                if not success:
                                    return Response({"error": current_node}, status=status.HTTP_400_BAD_REQUEST)
                            except Exception as e:
                                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
                            
                            else:
                                break
                        node_id = str(current_node.get("node_id", node_id))

            success, payload = NodeLoader(return_serialized=return_serialized, return_path=return_path, return_data=return_data)(node_id=node_id, project_id=project_id)

            # Filter by project_id if provided
            if project_id and payload:
                if str(payload.get('project_id')) != str(project_id):
                    return Response({"error": "Node does not belong to the specified project"}, 
                                  status=status.HTTP_400_BAD_REQUEST)
            
            return Response(payload, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        try:
            node_id = request.query_params.get("node_id")
            project_id = request.query_params.get('project_id')
            success, node = NodeLoader()(node_id=node_id, project_id=project_id)
            if success:
            # Check if node belongs to the specified project
                if project_id and str(node.get('project_id')) != str(project_id):
                    return Response({"error": "Node does not belong to the specified project"}, 
                                status=status.HTTP_400_BAD_REQUEST)
                
                # Check if node is a multi_channel node to delete it's dependencies
                node_name = node.get('node_name')
                is_multi_channel = node_name in MULTI_CHANNEL_NODES
                if not node_id:
                    return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
                try:
                    success, message = NodeDeleter(is_multi_channel)(node_id, project_id=project_id)
                    if success:
                        return Response({"message": f"Node {node_id} deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
                    else:
                        return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
                except Exception as e:
                    return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({"error": node}, status=status.HTTP_400_BAD_REQUEST)
            
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class BaseNodeAPIView(APIView, NodeQueryMixin):
    # cur_id is specified to layer nodes to give it an incremental name
    cur_id = 0
    def get_serializer_class(self):
        """Override this method to return the appropriate serializer class."""
        raise NotImplementedError

    def get_processor(self, validated_data, *args, **kwargs):
        """Override this method to return the processing class instance."""
        raise NotImplementedError

    def extract_node_id(self, value):
        """If value is a dictionary and contains 'node_id', return node_id; otherwise, return value itself."""
        if isinstance(value, dict) and "node_id" in value:
            return value["node_id"]
        return value

    def get_processor_and_args(self, request):
        # for multi-channel nodes, else it returns the parent one
        output_channel = request.query_params.get('output', None) 
        # return the node_data as hashed object for serialization
        return_serialized = request.query_params.get('return_serialized', '0') == '1'
        project_id = request.query_params.get('project_id') 
        node_id = request.query_params.get("node_id", None)

        if settings.TESTING:
            uid = 0
        else:
            try:
                # get uid component for node by its name
                ref = request.path.strip('/').split('/')[-1] + '/'
                node_name = get_node_name_by_api_ref(ref, request)
                uid = Component.objects.get(node_name=node_name).uid
            except Component.DoesNotExist:
                return Response({"error": f"Component with name {node_name} not found"}, status=status.HTTP_404_NOT_FOUND), None, None, None

        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            validated_data = serializer.validated_data

            # Extract node IDs from validated data if it's a dict
            for key in DICT_NODES:
                if key in validated_data:
                    validated_data[key] = self.extract_node_id(validated_data[key])
            
            # Check if project_id is in database, if not create a new project
            if project_id:
                try:
                    project_id = Project.objects.get(id=project_id).id
                except :
                    project_id = Project.objects.create(project_name="new_project", project_description="new_project_created").id
                
                validated_data['project_id'] = project_id
            processor = self.get_processor(validated_data, project_id=project_id, cur_id = BaseNodeAPIView.cur_id, uid=uid)
            BaseNodeAPIView.cur_id += 1

            return processor, return_serialized, output_channel, node_id, project_id
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST), None, None, None

    def post(self, request):

        result = self.get_processor_and_args(request)
        if isinstance(result[0], Response):
            return result[0]
        processor, return_serialized, output_channel, *_ = result

        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            response_data = processor(output_channel, return_serialized=return_serialized)
            if isinstance(response_data, str):
                return Response({"error": response_data}, status=status.HTTP_400_BAD_REQUEST)
            
            node_id = response_data.get("node_id")
            project_id = response_data.get("project_id")

            # Returns node_data chosen
            response_data["node_data"] = NodeDataExtractor(return_serialized=return_serialized, return_path = not return_serialized)(node_id, project_id=project_id)
            return Response(response_data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        result = self.get_processor_and_args(request)
        if isinstance(result[0], Response):
            return result[0]
        
        processor, return_serialized, _, node_id, project_id = result

        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            success, message = NodeUpdater(return_serialized)(node_id, project_id, processor())
            if isinstance(message, str):
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
            
            message["node_data"] = NodeDataExtractor(return_serialized=return_serialized, return_path=not return_serialized)(node_id, project_id=project_id)
            
            status_code = status.HTTP_200_OK if success else status.HTTP_400_BAD_REQUEST
            return Response(message if success else {"error": message}, status=status_code)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class DataLoaderAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return DataLoaderSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return DataLoader(
            dataset_name=validated_data.get("params", {}).get("dataset_name"),
            dataset_path=validated_data.get("params", {}).get("dataset_path"),
            **kwargs
        )


class TrainTestSplitAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return TrainTestSplitSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return TrainTestSplit(
            X=validated_data.get('X'),
            y=validated_data.get('y'),
            params=validated_data.get('params'),
            **kwargs
        )


class SplitterAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return SplitterSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Splitter(
            data=validated_data.get('data'),
            **kwargs
        )


class JoinerAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return JoinerSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Joiner(
            data_1=validated_data.get('data_1'), 
            data_2=validated_data.get('data_2'),
            **kwargs
        )


class CreateModelView(BaseNodeAPIView):
    def get_serializer_class(self):
        return ModelSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Model(
            model_name=validated_data.get('model_name'),
            model_type=validated_data.get('model_type'),
            task=validated_data.get('task'),
            params=validated_data.get('params'),
            model_path=validated_data.get('model_path'),
            **kwargs
        )


class FitModelAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return FitModelSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return FitModel(
            X=validated_data.get('X'),
            y=validated_data.get('y'),
            model=validated_data.get('model'),
            model_path=validated_data.get('model_path'),
            **kwargs
        )


class PredictAPIView(BaseNodeAPIView):
    """API view to handle predictions using a trained model."""

    def get_serializer_class(self):
        return PredictSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Predict(
            X=validated_data.get('X'),
            model=validated_data.get('fitted_model'),
            model_path=validated_data.get('fitted_model_path'),
            **kwargs
        )


class EvaluatorAPIView(BaseNodeAPIView):
    """API view to evaluate model predictions based on a given metric."""

    def get_serializer_class(self):
        return EvaluatorSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Evaluator(
            metric=validated_data.get("params", {}).get('metric', {'accuracy'}),
            y_true=validated_data.get('y_true'),
            y_pred=validated_data.get('y_pred'),
            **kwargs
        )


class PreprocessorAPIView(BaseNodeAPIView):
    """API view to create and update a Preprocessor instance."""

    def get_serializer_class(self):
        return PreprocessorSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Preprocessor(
            preprocessor_name=validated_data.get('preprocessor_name'),
            preprocessor_type=validated_data.get('preprocessor_type'),
            params=validated_data.get('params'),
            preprocessor_path=validated_data.get('preprocessor_path'),
            **kwargs
        )


class FitPreprocessorAPIView(BaseNodeAPIView):
    """API view for fitting a preprocessor on the given data."""

    def get_serializer_class(self):
        return FitPreprocessorSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return FitPreprocessor(
            data=validated_data.get('data'),
            preprocessor=validated_data.get('preprocessor'),
            preprocessor_path=validated_data.get('preprocessor_path'),
            **kwargs
        )


class TransformAPIView(BaseNodeAPIView):
    """API view for transforming data using a given preprocessor."""

    def get_serializer_class(self):
        return TransformSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Transform(
            data=validated_data.get('data'),
            preprocessor=validated_data.get('fitted_preprocessor'),
            preprocessor_path=validated_data.get('fitted_preprocessor_path'),
            **kwargs
        )


class FitTransformAPIView(BaseNodeAPIView):
    """API view for fitting and transforming data using a given preprocessor."""

    def get_serializer_class(self):
        return FitTransformSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return FitTransform(
            data=validated_data.get('data'),
            preprocessor=validated_data.get('preprocessor'),
            preprocessor_path=validated_data.get('preprocessor_path'),
            **kwargs
        )


class InputAPIView(BaseNodeAPIView):
    """API view for handling input layers."""

    def get_serializer_class(self):
        return InputSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return InputLayer(
            shape=validated_data.get("params", {}).get("shape", (1,)),
            name=validated_data.get("name"),
            path=validated_data.get("path"),
            **kwargs
        )


class Conv2DAPIView(BaseNodeAPIView):
    """API view for handling Conv2D layers."""

    def get_serializer_class(self):
        return Conv2DSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return Conv2DLayer(
            prev_node=validated_data.get("prev_node"),
            filters=validated_data.get("params", {}).get("filters", 32),
            kernel_size=validated_data.get("params", {}).get("kernel_size", [3,3]),
            strides=validated_data.get("params", {}).get("strides", (1,1)),
            padding=validated_data.get("params", {}).get("padding", "valid"),
            activation=validated_data.get("params", {}).get("activation", "relu"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
            **kwargs
        )


class MaxPool2DAPIView(BaseNodeAPIView):
    """API view for handling MaxPool2D layers."""

    def get_serializer_class(self):
        return MaxPool2DSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return MaxPool2DLayer(
            prev_node=validated_data.get("prev_node"),
            pool_size=validated_data.get("params", {}).get("pool_size", [2,2]),
            strides=validated_data.get("params", {}).get("strides", (2,2)),
            padding=validated_data.get("params", {}).get("padding", "valid"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
            **kwargs
        )


class FlattenAPIView(BaseNodeAPIView):
    """API view for handling Flatten layers."""

    def get_serializer_class(self):
        return FlattenSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return FlattenLayer(
            prev_node=validated_data.get("prev_node"),
            name=validated_data.get("name"),
            path=validated_data.get("path"),
            **kwargs
        )


class DenseAPIView(BaseNodeAPIView):
    """API view for handling dense layers."""

    def get_serializer_class(self):
        return DenseSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return DenseLayer(
            prev_node=validated_data.get("prev_node"),
            units=validated_data.get("params", {}).get("units", 128),
            activation=validated_data.get("params", {}).get("activation", "relu"),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
            **kwargs
        )


class DropoutAPIView(BaseNodeAPIView):
    """API view for handling Dropout layers."""

    def get_serializer_class(self):
        return DropoutSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return DropoutLayer(
            prev_node=validated_data.get("prev_node"),
            rate=validated_data.get("params", {}).get("rate", 0.5),
            path=validated_data.get("path"),
            name=validated_data.get("name"),
            **kwargs
        )


class SequentialAPIView(BaseNodeAPIView):
    """API view for handling Sequential models."""

    def get_serializer_class(self):
        return SequentialSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return SequentialNet(
            layer=validated_data.get("layer"),
            name=validated_data.get("name"),
            path=validated_data.get("path"),
            **kwargs
        )

class ModelCompilerAPIView(BaseNodeAPIView):
    """API view for handling model compilation."""

    def get_serializer_class(self):
        return ModelCompilerSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return CompileModel(
            nn_model=validated_data.get("nn_model"),
            optimizer=validated_data.get("params", {}).get("optimizer", "adam"),
            loss=validated_data.get("params", {}).get("loss", "categorical_crossentropy"),
            metrics=validated_data.get("params", {}).get("metrics", ["accuracy"]),
            **kwargs
        )

class NetModelFitterAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return NetModelFitterSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return FitNet(
            model=validated_data.get("compiled_model"),
            X = validated_data.get("X"),
            y = validated_data.get("y"),
            batch_size = validated_data.get("params",{}).get("batch_size", 32),
            epochs = validated_data.get("params",{}).get("epochs", 10),
            **kwargs
        )

class NodeLoaderAPIView(APIView, NodeQueryMixin):

    def get_serialized_payload(self, path, return_serialized, project_id):
        """Loads a node, saves it, and optionally serializes it."""
        loader = NodeLoader(from_db=False)
        success, payload = loader(project_id= project_id, path=path)
        node_name = payload.get("message").split(" ")[1]
        uid = Component.objects.get(node_name="node_loader").uid
        payload.update({"node_name":node_name,
                        "project_id": project_id,
                        "uid": uid})
        
        project_path = f"{project_id}/" if project_id else ""
        NodeSaver()(payload, path=rf"{SAVING_DIR}/{project_path}other")

        # Reload the node with serialization settings
        success, payload = NodeLoader(return_serialized=return_serialized, return_path= not return_serialized)(node_id=payload.get("node_id"), project_id=project_id)
        return payload
    
    def post(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            try:
                path = serializer.validated_data.get('params', {}).get('node_path')
                return_serialized = request.query_params.get("return_serialized") == "1"
                project_id = request.query_params.get('project_id')

                try:
                    project_id = Project.objects.get(id=project_id).id
                except :
                    project_id = Project.objects.create(project_name="new_project", project_description="new_project_created").id
                
                payload = self.get_serialized_payload(path, return_serialized, project_id)
                return Response(payload, status=status.HTTP_200_OK)
            
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            try:
                path = serializer.validated_data.get("params", {}).get('node_path')
                return_serialized = request.query_params.get("return_serialized") == "1"
                project_id = request.query_params.get('project_id')

                try:
                    project_id = Project.objects.get(id=project_id).id
                except :
                    project_id = Project.objects.create(project_name="new_project", project_description="new_project_created").id

                payload = self.get_serialized_payload(path, return_serialized, project_id)
                node_id = request.query_params.get("node_id", None)
                success, message = NodeUpdater(return_serialized)(node_id, project_id, payload)

                message["node_data"] = NodeDataExtractor(return_serialized=return_serialized, return_path=not return_serialized)(node_id, project_id=project_id)
                        
                if success:
                    return Response({"message": message}, status=status.HTTP_200_OK)
                else:
                    return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        

class NodeSaveAPIView(APIView, NodeQueryMixin):
    def process_node_save(self, request):
        """Handles node saving logic for both POST and PUT requests."""
        payload = request.data.get("node")
        path = request.data.get("node_path")  # Optional path parameter
        project_id = request.query_params.get('project_id')
        return_serialized = request.query_params.get("return_serialized") == "1"
        uid = Component.objects.get(node_name="node_saver").uid
        try:
            saver = NodeSaver()
            if isinstance(payload, int):
                success, payload = NodeLoader()(node_id=payload, project_id=project_id)
            node_data = NodeDataExtractor()(payload, project_id=project_id)
            payload["node_data"] = node_data
            payload["node_id"] = id(saver)
            try:
                project_id = Project.objects.get(id=project_id).id
            except :
                project_id = Project.objects.create(project_name="new_project", project_description="new_project_created").id
                
            payload.update({"project_id": project_id, 
                            "uid": uid})
            saved_response = saver(payload, path=path)
            response = saver(saved_response)

            if return_serialized:
                node_data = NodeDataExtractor(return_serialized=True)(response, project_id=project_id)
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
        serializer, project_id = NodeSaverSerializer(data=request.data)
        if serializer.is_valid():
            response = self.process_node_save(request)
            response_data = response.data
            node_id = request.query_params.get("node_id")
            project_id = request.query_params.get('project_id')
            return_serialized = request.query_params.get("return_serialized") == "1"

            success, message = NodeUpdater(return_serialized)(node_id, project_id, response_data)

            if return_serialized:
                message["node_data"] = NodeDataExtractor(return_serialized=True)(message, project_id=project_id)
            else:
                message["node_data"] = NodeDataExtractor(return_path=True)(message, project_id=project_id)

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
            project_id = request.query_params.get('project_id')
            response = ClearAllNodes()(project_id=project_id)
            return Response(response, status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ClearComponentsAPIView(APIView):
    def delete(self, request):
        try:
            response = ClearAllNodes()('components')
            return Response(response, status=status.HTTP_204_NO_CONTENT)
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


class NodeAPIViewSet(viewsets.ModelViewSet, NodeQueryMixin):
    queryset = Node.objects.all()
    serializer_class = NodeSerializer
    http_method_names = ['get', 'post', 'put', 'patch', 'delete']

    
    def create(self, request, *args, **kwargs):
        """Handle bulk creation of nodes with project assignment"""
        project_id = request.query_params.get('project_id')
        
        # Get project instance if project_id is provided
        if project_id:
            try:
                Project.objects.get(id=project_id)
            except Project.DoesNotExist:
                return Response({"error": f"Project with id {project_id} does not exist"}, 
                              status=status.HTTP_400_BAD_REQUEST)

        if isinstance(request.data, list):
            # Handle bulk creation
            data = request.data.copy()
            for item in data:
                if project_id:
                    item['project_id'] = project_id
                if item.get('project'):
                    item.pop('project')
                    
            serializer = self.get_serializer(data=data, many=True)
        else:
            # Handle single node creation
            data = request.data.copy()
            if project_id:
                data['project_id'] = project_id
            serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        """Handle both single and bulk updates"""
        if isinstance(request.data, list):
            # Handle bulk update
            updated_nodes = []
            project_id = request.query_params.get('project_id')
            
            # Get project instance if project_id is provided
            project = None
            if project_id:
                try:
                    project = Project.objects.get(id=project_id)
                except Project.DoesNotExist:
                    return Response({"error": f"Project with id {project_id} does not exist"}, 
                                  status=status.HTTP_400_BAD_REQUEST)
            
            for item in request.data:
                node_id = item.get('node_id')
                if not node_id:
                    continue
                
                try:
                    instance = Node.objects.get(node_id=node_id, project_id=project_id)
                    # Update fields directly
                    for field, value in item.items():
                        if field not in ['node_id', 'project_id', 'project']:  # Skip node_id as it shouldn't be updated
                            setattr(instance, field, value)
                    
                    # Set project if provided in query params
                    
                    if project and not project_id:
                        instance.project = project
                        
                    instance.save()
                    updated_nodes.append(self.get_serializer(instance).data)
                except Node.DoesNotExist:
                    continue
                    
            return Response(updated_nodes, status=status.HTTP_200_OK)
        else:
            # Handle single update
            return super().update(request, *args, **kwargs)

    def get_queryset(self):
        """Filter nodes by project if project_id is provided in query params"""
        queryset = Node.objects.all()
        project_id = self.request.query_params.get('project_id', None)
        if project_id:
            queryset = queryset.filter(project_id=project_id)
        
        return queryset

    def get_serializer_context(self):
        """Pass additional context to the serializer"""
        context = super().get_serializer_context()
        context["return_serialized"] = self.request.query_params.get("return_serialized", "0") == "1"
        return context


class ExportProjectAPIView(APIView):
    """API view for exporting project nodes as JSON or AINOPRJ format via POST request."""
    
    def post(self, request, *args, **kwargs):
        try:
            # Validate request body using serializer
            serializer = ExportProjectSerializer(data=request.data)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
            # Extract validated data
            default_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'exports')
            save_path = serializer.validated_data.get('folder_path', default_path)
            file_name = serializer.validated_data.get('file_name', 'exported_project')
            format_type = serializer.validated_data.get('format', 'ainoprj').lower()
            save_path = os.path.join(save_path, f'{file_name}.{format_type}')
            # encrypt = serializer.validated_data.get('encrypt', False)
            password = serializer.validated_data.get('password')
            encrypt = not(password == None)
            if not password:
                password = ''
            # Get project_id from query parameters
            project_id = request.query_params.get('project_id')
            if not project_id:
                return Response({"error": "Project ID is required"}, status=status.HTTP_400_BAD_REQUEST)
                
            # Check if project exists
            try:
                project = Project.objects.get(id=project_id)
            except Project.DoesNotExist:
                return Response({"error": f"Project with ID {project_id} does not exist"}, 
                              status=status.HTTP_404_NOT_FOUND)
                
            # Get all nodes for the project
            nodes = Node.objects.filter(project_id=project_id)
            serializer = NodeSerializer(nodes, many=True)
            
            # Create export data with project info and nodes
            export_data = {
                "project_id": project_id,
                "project_name": project.project_name,
                "project_description": project.project_description,
                "export_date": datetime.datetime.now().isoformat(),
                "nodes": serializer.data
            }
            # Convert to JSON 
            json_data = json.dumps(export_data, indent=4)
            
            # Generate base filename for exports
            base_filename = f"{project.project_name.replace(' ', '_')}_export_{datetime.datetime.now().strftime('%Y%m%d')}"
            
            # Handle JSON format
            if format_type == 'json':
                if save_path:
                    try:
                        # Ensure directory exists
                        os.makedirs(os.path.dirname(save_path), exist_ok=True)
                        
                        # Save to file
                        with open(save_path, 'w') as f:
                            f.write(json_data)
                        
                        return Response({
                            "success": True,
                            "message": f"Project exported successfully to {save_path}",
                            "path": save_path,
                            "format": "JSON",
                            
                        }, status=status.HTTP_200_OK)
                        
                    except Exception as e:
                        return Response({
                            "error": f"Failed to save file: {str(e)}",
                            "path": save_path
                        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                else:
                    # Create file response for download
                    response = HttpResponse(json_data, content_type='application/json')
                    response['Content-Disposition'] = f'attachment; filename="{base_filename}.json"'
                    return response
                    
            # Handle AINOPRJ format conversion
            elif format_type == 'ainoprj':
                # Create temporary JSON file
                with tempfile.NamedTemporaryFile(suffix='.json', delete=False, mode='w') as temp_json:
                    temp_json.write(json_data)
                    temp_json_path = temp_json.name
                
                # Define output path for AINOPRJ
                if save_path:
                    output_path = save_path
                else:
                    # Create temporary output file for download
                    temp_ainoprj = tempfile.NamedTemporaryFile(suffix='.ainoprj', delete=False)
                    output_path = temp_ainoprj.name
                    temp_ainoprj.close()
                
                try:
                    # Get path to converter script (relative to this file)
                    converter_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'jsonAinoConverter.py')
                    if not os.path.exists(converter_path):
                        return Response({
                            "error": f"Converter script not found at path: {converter_path}"
                        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                    
                    python_executable = sys.executable
                    # Run converter script
                    result = subprocess.run([
                        python_executable, 
                        converter_path,
                        'json', 
                        'ainoprj', 
                        temp_json_path, 
                        output_path, 
                        'True' if encrypt else 'False',
                        password
                    ], check=True, capture_output=True, text=True)

                    print(f"Converter stdout: {result.stdout}")
                    print(f"Converter stderr: {result.stderr}")
                    
                    # Clean up temporary JSON file
                    os.unlink(temp_json_path)
                    
                    if save_path:
                        return Response({
                            "success": True,
                            "message": f"Project exported successfully to {save_path}",
                            "path": save_path,
                            "format": "AINOPRJ",
                            "encrypted": encrypt
                        }, status=status.HTTP_200_OK)
                    else:
                        # Return the file for download
                        with open(output_path, 'rb') as f:
                            content = f.read()
                        
                        # Clean up temporary AINOPRJ file
                        os.unlink(output_path)
                        
                        response = HttpResponse(content, content_type='application/octet-stream')
                        response['Content-Disposition'] = f'attachment; filename="{base_filename}.ainoprj"'
                        return response
                        
                except subprocess.CalledProcessError as e:
                    # Clean up temporary files
                    if os.path.exists(temp_json_path):
                        os.unlink(temp_json_path)
                    if not save_path and os.path.exists(output_path):
                        os.unlink(output_path)
                    
                    return Response({
                        "error": f"Converter script failed: {e.stderr}"
                    }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                except Exception as e:
                    # Clean up temporary files
                    if os.path.exists(temp_json_path):
                        os.unlink(temp_json_path)
                    if not save_path and os.path.exists(output_path):
                        os.unlink(output_path)
                    
                    return Response({
                        "error": f"Failed to convert to AINOPRJ format: {str(e)}"
                    }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            else:
                return Response({
                    "error": f"Invalid format: {format_type}. Supported formats: json, ainoprj"
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



# Add to views.py
class ImportProjectAPIView(APIView):
    """API view for importing project nodes from JSON or AINOPRJ format."""
    
    def get(self, request, *args, **kwargs):
        try:
            # Validate request body using serializer
            serializer = ImportProjectSerializer(data=request.data)
            if not serializer.is_valid():
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
            # Extract validated data
            file_path = serializer.validated_data['path']
            format_type = serializer.validated_data.get('format', 'auto')
            password = serializer.validated_data.get('password')
            encrypt = "1" if password else "0"
            if encrypt == "1" and not password:
                return Response({"error": "Please change encryption to 0 or add a password"}, status=status.HTTP_400_BAD_REQUEST)
            
            replace = request.query_params.get('replace', '1') == '1'   # if specified to '0' it will remain nodes, else it will replace them
            # Get project_id from query parameters
            project_id = request.query_params.get('project_id')
            if not project_id:
                project_id = Project.objects.create(project_name="Imported Project").id
                
            # Check if project exists
            try:
                project = Project.objects.get(id=project_id)
            except Project.DoesNotExist:
                # Project doesn't exist, create a new one
                project = Project.objects.create(project_name="Imported Project")
                project_id = project.id
                
            
            # Verify file exists
            if not os.path.exists(file_path):
                return Response({"error": f"File not found: {file_path}"}, 
                              status=status.HTTP_404_NOT_FOUND)
                
            # Auto-detect format if not specified
            if format_type == 'auto':
                _, ext = os.path.splitext(file_path.lower())
                if ext == '.json':
                    format_type = 'json'
                elif ext == '.ainoprj':
                    format_type = 'ainoprj'
                else:
                    return Response({"error": f"Cannot auto-detect format for extension: {ext}"}, 
                                  status=status.HTTP_400_BAD_REQUEST)
            
            json_data = None
            
            # Process based on format
            if format_type == 'json':
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        json_data = json.load(f)
                        if isinstance(json_data, dict):
                            json_data = json_data.get('nodes', [])

                except json.JSONDecodeError as e:
                    return Response({"error": f"Invalid JSON format: {str(e)}"}, 
                                  status=status.HTTP_400_BAD_REQUEST)
                    
            elif format_type == 'ainoprj':
                try:
                    # Create a temporary file for the JSON output
                    with tempfile.NamedTemporaryFile(suffix='.json', delete=False, mode='w') as temp_json:
                        temp_json_path = temp_json.name
                    
                    # Get path to converter script
                    converter_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'jsonAinoConverter.py')
                    if not os.path.exists(converter_path):
                        return Response({
                            "error": f"Converter script not found at path: {converter_path}"
                        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                    
                    # Run converter script to convert AINOPRJ to JSON
                    python_executable = sys.executable
                    cmd = [
                        python_executable,
                        converter_path,
                        'ainoprj',
                        'json',
                        file_path,
                        temp_json_path,
                        encrypt,
                    ]
                    
                    # Add password if provided
                    if password:
                        cmd.append(password)
                        
                    result = subprocess.run(cmd, check=True, capture_output=True, text=True)
                    
                    # Load the converted JSON
                    with open(temp_json_path, 'r', encoding='utf-8') as f:
                        json_data = json.load(f)
                        
                    # Clean up temporary file
                    os.unlink(temp_json_path)
                    
                except subprocess.CalledProcessError as e:
                    if os.path.exists(temp_json_path):
                        os.unlink(temp_json_path)
                    error_msg = e.stderr if e.stderr else str(e)
                    return Response({
                        "error": f"Converter script failed: {error_msg}"
                    }, status=status.HTTP_400_BAD_REQUEST)
                except Exception as e:
                    if os.path.exists(temp_json_path):
                        os.unlink(temp_json_path)
                    return Response({
                        "error": f"Failed to convert AINOPRJ file: {str(e)}"
                    }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            # Process the imported data
            if not json_data:
                return Response({"error": "No valid data found in the import file"}, 
                              status=status.HTTP_400_BAD_REQUEST)
            
            # Extract nodes from the JSON data
            nodes_data = json_data
            
            if not nodes_data:
                return Response({"error": "No nodes found in the import file"}, 
                              status=status.HTTP_400_BAD_REQUEST)
            
            if replace:
                # Clear existing nodes for the project
                Node.objects.filter(project_id=project_id).delete()
            # Prepare nodes for import by setting the project_id
            for node in nodes_data:
                node['project_id'] = project_id
                [node.pop(i, None) for i in ['project', 'node_data']]
                
            
            # Create the nodes in the database
            node_serializer = NodeSerializer(data=nodes_data, many=True)
            if node_serializer.is_valid():
                created_nodes = node_serializer.save()
                return Response({
                    "success": True,
                    "message": f"Successfully imported {len(created_nodes)} nodes into project '{project.project_name}'",
                    "imported_nodes_count": len(created_nodes),
                    "project_id": project_id,
                    "project_name": project.project_name
                }, status=status.HTTP_201_CREATED)
            else:
                return Response({
                    "error": "Failed to import nodes",
                    "validation_errors": node_serializer.errors
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        if serializer.is_valid():
            self.perform_update(serializer)
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        project_id = instance.id
    
        # Delete all associated nodes first
        node_count = Node.objects.filter(project_id=project_id).delete()[0]
        self.perform_destroy(instance)
        return Response({
            "success": True,
            "message": f"Project deleted successfully with {node_count} associated nodes",
        }, status=status.HTTP_200_OK)

class BulkProjectDeleteAPIView(APIView):
    """API view for deleting multiple projects at once."""
    
    def delete(self, request):
        try:
            # Extract project IDs from request data
            project_ids = request.data.get('project_ids', [])
            
            if not project_ids:
                return Response({"error": "No project IDs provided"}, 
                              status=status.HTTP_400_BAD_REQUEST)
            
            if not isinstance(project_ids, list):
                return Response({"error": "project_ids must be a list"}, 
                              status=status.HTTP_400_BAD_REQUEST)
            
            # Track deletion results
            deleted_count = 0
            not_found_ids = []
            error_ids = []
            
            # Process each project ID
            for project_id in project_ids:
                try:
                    project = Project.objects.get(id=project_id)
                    
                    # Delete associated nodes first
                    node_count = Node.objects.filter(project_id=project_id).delete()[0]
                    
                    # Delete the project
                    project.delete()
                    deleted_count += 1
                    
                except Project.DoesNotExist:
                    not_found_ids.append(project_id)
                except Exception as e:
                    error_ids.append({"id": project_id, "error": str(e)})
            
            # Prepare response data
            response_data = {
                "success": True,
                "deleted_count": deleted_count,
                "total_requested": len(project_ids)
            }
            
            if not_found_ids:
                response_data["not_found_ids"] = not_found_ids
            
            if error_ids:
                response_data["errors"] = error_ids
                
            # Return appropriate status code
            if deleted_count == 0:
                if not_found_ids and not error_ids:
                    return Response(response_data, status=status.HTTP_404_NOT_FOUND)
                return Response(response_data, status=status.HTTP_400_BAD_REQUEST)
            
            return Response(response_data, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ChatbotAPIView(APIView):
    """API endpoint for interacting with the chatbot."""
    history = []
    
    def post(self, request, *args, **kwargs):
        try:
            # Extract required parameters
            query = request.data.get('query')
            mode = request.data.get('mode', 'manual')  # Default to manual mode
            project_id = request.query_params.get('project_id')
            route = request.data.get("route", "chat")

            if project_id:
                try:
                    project_id = Project.objects.get(id=project_id).id
                except Project.DoesNotExist:
                    project_id = Project.objects.create(project_name="new_project", project_description="new_project_created").id

                call_script(f"select_project {project_id}")
            modes = {
                "manual": '1',
                "auto": '2'
            }
            if mode in modes.keys():
                mode = modes[mode]
                
            model_name = request.data.get('model_name', 'gemini-1.5-pro')  # Default model
            iteration = request.data.get('iteration', 0)  # Current iteration
            to_db = request.data.get('to_db', False)  # Flag for database usage
            
            if route in ['1', 'chat']:
                to_db = False
                mode = 'manual'

            
            if not query:
                return Response({"error": "Query is required"}, status=status.HTTP_400_BAD_REQUEST)
                
            # Validate mode
            if mode not in ['1', '2', 'manual', 'auto']:
                return Response({"error": "Mode must be '1' (manual) or '2' (auto)"}, 
                              status=status.HTTP_400_BAD_REQUEST)

            if route not in ['chat', '1', 'agent', '2']:
                return Response({"error": "Choose 'agent' or 'chat'"}, status=status.HTTP_400_BAD_REQUEST)
            
            response, logs, hist = sync_generate_cli(user_input=query, to_db=to_db, model=model_name, selected_mode=mode, cur_iter=iteration, route=route, history=ChatbotAPIView.history)
            
            ChatbotAPIView.history = hist
            return Response({"output": response, "status": "success", "logs": logs}, status=status.HTTP_200_OK)
        
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



class CLIAPIView(APIView):
    def post(self, request, *args, **kwargs):
        try:
            command = request.data.get('command')
            
            if not command:
                return Response({"error": "Command is required"}, status=status.HTTP_400_BAD_REQUEST)
            
            # Call the CLI script with the provided command and parameters
            response = call_script(command)
            
            return Response(response, status=status.HTTP_200_OK)
        
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


