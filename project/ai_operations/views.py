from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.views import APIView, Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser

from core.nodes import *
from core.repositories import *

from .serializers import *
import pandas as pd
import json

class NodeQueryMixin:
    """
    A mixin to handle 'get' requests for any ViewSet.
    It extracts "node_id" from request parameters and uses NodeLoader.
    """
    def get(self, request, *args, **kwargs):
        try:
            node_id = request.query_params.get("node_id")
            output = request.query_params.get('output', "0")
            return_serialized = request.query_params.get('return_serialized', '0') == '1'
            return_path = not return_serialized
            project_id = request.query_params.get('project_id')

            if output.isdigit() and int(output) > 0:
                depth = int(output)
                current_node = NodeLoader(return_path=return_path)(node_id=node_id)
                children = current_node.get("children", [])
                if len(current_node.get("children")) > 1:
                    child_id = children[int(output) - 1] if len(children) >= int(output) else None
                    if isinstance(child_id, int):
                        current_node = NodeLoader(return_path=return_path)(node_id=str(child_id))
                        node_id = str(child_id)
                else:
                    for i in range(depth):
                        child = current_node.get("children", [])
                        if child:
                            child_id = child[0]
                            current_node = NodeLoader(return_path=return_path)(node_id=str(child_id))
                        else:
                            break
                        node_id = str(current_node.get("node_id", node_id))

            payload = NodeLoader(return_serialized=return_serialized, return_path=return_path)(node_id=node_id)
            
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
            node = NodeLoader()(node_id=node_id)
            
            # Check if node belongs to the specified project
            if project_id and str(node.get('project_id')) != str(project_id):
                return Response({"error": "Node does not belong to the specified project"}, 
                              status=status.HTTP_400_BAD_REQUEST)
                
            node_name = node.get('node_name')
            is_multi_channel = node_name in MULTI_CHANNEL_NODES
            if not node_id:
                return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
            try:
                success, message = NodeDeleter(is_multi_channel)(node_id)
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

    def get_processor(self, validated_data, *args, **kwargs):
        """Override this method to return the processing class instance."""
        raise NotImplementedError

    def extract_node_id(self, value):
        """If value is a dictionary and contains 'node_id', return node_id; otherwise, return value itself."""
        if isinstance(value, dict) and "node_id" in value:
            return value["node_id"]
        return value

    def post(self, request):

        output_channel = request.query_params.get('output', None)
        return_serialized = request.query_params.get('return_serialized', '0') == '1'
        project_id = request.query_params.get('project_id')

        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            validated_data = serializer.validated_data

            for key in DICT_NODES:
                if key in validated_data:
                    validated_data[key] = self.extract_node_id(validated_data[key])
            
            if project_id:
                validated_data['project_id'] = project_id
            processor = self.get_processor(validated_data, project_id=project_id)
            
            response_data = processor(output_channel, return_serialized=return_serialized)
            node_id = response_data.get("node_id")
            response_data["node_data"] = NodeDataExtractor(return_serialized=return_serialized, return_path=not return_serialized)(node_id)
            return Response(response_data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):

        project_id = request.query_params.get('project_id')
        node_id = request.query_params.get("node_id", None)
        return_serialized = request.query_params.get('return_serialized', '0') == '1'
        
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)
        if serializer.is_valid():
            validated_data = serializer.validated_data
            if project_id:
                validated_data['project_id'] = project_id

            processor = self.get_processor(validated_data, project_id=project_id)
            success, message = NodeUpdater(return_serialized)(node_id, processor())
            message["node_data"] = NodeDataExtractor(return_serialized=return_serialized, return_path=not return_serialized)(node_id)
            
            status_code = status.HTTP_200_OK if success else status.HTTP_400_BAD_REQUEST
            return Response(message if success else {"error": message}, status=status_code)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DataLoaderAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return DataLoaderSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return DataLoader(
            dataset_name=validated_data.get("params", {}).get("dataset_name"),
            dataset_path=validated_data.get('dataset_path'),
            **kwargs
        )


class TrainTestSplitAPIView(BaseNodeAPIView):
    def get_serializer_class(self):
        return TrainTestSplitSerializer

    def get_processor(self, validated_data, *args, **kwargs):
        return TrainTestSplit(
            data=validated_data.get('data'),
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
            model=validated_data.get('model'),
            model_path=validated_data.get('model_path'),
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
            preprocessor=validated_data.get('preprocessor'),
            preprocessor_path=validated_data.get('preprocessor_path'),
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
            model=validated_data.get("model"),
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
            model=validated_data.get("model"),
            X = validated_data.get("X"),
            y = validated_data.get("y"),
            batch_size = validated_data.get("params",{}).get("batch_size", 32),
            epochs = validated_data.get("params",{}).get("epochs", 10),
            **kwargs
        )

class NodeLoaderAPIView(APIView, NodeQueryMixin):

    def get_serialized_payload(self, node_id, path, return_serialized, project_id):
        """Loads a node, saves it, and optionally serializes it."""
        loader = NodeLoader(from_db=False)
        payload = loader(node_id=node_id, path=path)
        node_name = payload.get("message").split(" ")[1]
        payload.update({"node_name":node_name,
                        "project_id": project_id})
        
        NodeSaver()(payload, path=rf"{SAVING_DIR}\other")

        # Reload the node with serialization settings
        payload = NodeLoader(return_serialized=return_serialized, return_path= not return_serialized)(node_id=payload.get("node_id"))
        return payload
    
    def post(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            try:
                node_id = serializer.validated_data.get("node_id")
                path = serializer.validated_data.get('node_path')
                return_serialized = request.query_params.get("return_serialized") == "1"
                project_id = request.query_params.get('project_id')
                
                payload = self.get_serialized_payload(node_id, path, return_serialized, project_id)
                return Response(payload, status=status.HTTP_200_OK)
            
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            node_id = serializer.validated_data.get("node_id")
            path = serializer.validated_data.get('node_path')
            return_serialized = request.query_params.get("return_serialized") == "1"
            project_id = request.query_params.get('project_id')
            payload = self.get_serialized_payload(node_id, path, return_serialized, project_id)
            
            node_id = request.query_params.get("node_id", None)
            success, message = NodeUpdater(return_serialized)(node_id, payload)

            message["node_data"] = NodeDataExtractor(return_serialized=return_serialized, return_path=not return_serialized)(node_id)
                    
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
        project_id = request.query_params.get('project_id')
        return_serialized = request.query_params.get("return_serialized") == "1"
        try:
            saver = NodeSaver()
            if isinstance(payload, int):
                payload = NodeLoader()(node_id=payload)
            node_data = NodeDataExtractor()(payload)
            payload["node_data"] = node_data
            payload["node_id"] = id(saver)
            payload.update({"project_id": project_id})
            saved_response = saver(payload, path=path)
            response = saver(saved_response)

            if return_serialized:
                node_data = NodeDataExtractor(return_serialized=True)(response)
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
                message["node_data"] = NodeDataExtractor(return_serialized=True)(message)
            else:
                message["node_data"] = NodeDataExtractor(return_path=True)(message)

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
                    instance = Node.objects.get(node_id=node_id)
                    # Update fields directly
                    for field, value in item.items():
                        if field != 'node_id':  # Skip node_id as it shouldn't be updated
                            setattr(instance, field, value)
                    
                    # Set project if provided in query params
                    if project:
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
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)

