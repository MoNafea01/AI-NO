from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.views import APIView, Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser
from core.nodes.other.dataLoader import DataLoader
from core.nodes.model.model import Model
from core.nodes.model.fit import Fit as FitModel
from core.nodes.model.predict import Predict
from core.nodes.preprocessing.preprocessor import Preprocessor
from core.nodes.preprocessing.transform import Transform
from core.nodes.other.train_test_split import TrainTestSplit
from core.nodes.preprocessing.fit_transform import FitTransform
from core.nodes.preprocessing.fit import Fit as FitPreprocessor
from core.repositories.node_repository import NodeLoader, NodeSaver, NodeDeleter, NodeUpdater, ClearAllNodes
from core.nodes.other.custom import Joiner, Splitter
from core.nodes.other.evaluator import Evaluator
from .serializers import *
import pandas as pd
import json


class NodeQueryMixin:
    """
    A mixin to handle 'get' requests for any ViewSet.
    It extracts 'node_id' from request parameters and uses NodeLoader.
    """
    def get(self, request, *args, **kwargs):
        try:
            node_id = request.query_params.get('node_id')
            channel = request.query_params.get('output')
            if channel == '1':
                node = Node.objects.filter(node_id=int(node_id)+1)
                if node.exists():
                    node_id = str(int(node_id) + 1)
            elif channel in ['2', 'data']:
                node = Node.objects.filter(node_id=int(node_id)+2)
                if node.exists():
                    node_id = str(int(node_id) + 2)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            payload = NodeLoader()(node_id=node_id, from_db=True, return_serialized=return_serialized)
            if not return_serialized:
                del payload['node_data']
            return Response(payload, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CreateModelView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = ModelSerializer(data=request.data)
        if serializer.is_valid():
            # Extract data from the serializer
            data = serializer.validated_data
            # Create Model instance using the data
            model_instance = Model(
                model_name=data.get('model_name'),
                model_type=data.get('model_type'),
                task=data.get('task'),
                params=data.get('params'),
                model_path= data.get('model_path'),
            )
            output_channel = request.query_params.get('output', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            response_data = model_instance(output_channel, return_serialized=return_serialized)
            return Response(response_data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = ModelSerializer(data=request.data)
        if serializer.is_valid():
            # Extract data from the serializer
            data = serializer.validated_data
            # Create Model instance using the data
            model_instance = Model(
                model_name=data.get('model_name'),
                model_type=data.get('model_type'),
                task=data.get('task'),
                params=data.get('params'),
                model_path= data.get('model_path'),
            )
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, model_instance(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class FitModelAPIView(APIView, NodeQueryMixin):
    def post(self, request, *args, **kwargs):
        serializer = FitModelSerializer(data=request.data)
        if serializer.is_valid():
            try:
                # Extract validated data
                X = serializer.validated_data.get('X')
                y = serializer.validated_data.get('y')
                model = serializer.validated_data.get('model')
                model_path = serializer.validated_data.get('model_path')

                # Instantiate Fit and perform the fitting
                fitter = FitModel(X=X, y=y, model=model, model_path=model_path)
                output_channel = request.query_params.get('output', None)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                response_data = fitter(output_channel, return_serialized=return_serialized)

                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = FitModelSerializer(data=request.data)
        if serializer.is_valid():
            # Extract data from the serializer
            X = serializer.validated_data.get('X')
            y = serializer.validated_data.get('y')
            model = serializer.validated_data.get('model')
            model_path = serializer.validated_data.get('model_path')

            # Instantiate Fit and perform the fitting
            fitter = FitModel(X=X, y=y, model=model, model_path=model_path)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, fitter(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response( message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class PredictAPIView(APIView, NodeQueryMixin):
    """
    API view to handle predictions using a trained model.
    """

    def post(self, request, *args, **kwargs):
        serializer = PredictSerializer(data=request.data)
        if serializer.is_valid():
            X = serializer.validated_data.get('X')
            model = serializer.validated_data.get('model')
            model_path = serializer.validated_data.get('model_path')

            try:
                # Perform prediction
                predictor = Predict(X, model=model, model_path=model_path)
                output_channel = request.query_params.get('output', None)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                response_data = predictor(output_channel, return_serialized=return_serialized)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
            serializer = PredictSerializer(data=request.data)
            if serializer.is_valid():
                # Extract data from the serializer
                X = serializer.validated_data.get('X')
                model = serializer.validated_data.get('model')
                model_path = serializer.validated_data.get('model_path')

                # Instantiate Fit and perform the fitting
                predictor = Predict(X, model=model, model_path=model_path)
                node_id = request.query_params.get('node_id', None)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                success, message = NodeUpdater()(node_id, predictor(), return_serialized=return_serialized)
                if not return_serialized:
                    del message["node_data"]
                if success:
                    return Response(message, status=status.HTTP_200_OK)
                else:
                    return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class PreprocessorAPIView(APIView, NodeQueryMixin):
    """
    API view to create a Preprocessor instance.
    """

    def post(self, request, *args, **kwargs):
        serializer = PreprocessorSerializer(data=request.data)
        if serializer.is_valid():
            preprocessor_name = serializer.validated_data.get('preprocessor_name')
            preprocessor_type = serializer.validated_data.get('preprocessor_type')
            params = serializer.validated_data.get('params')
            preprocessor_path = serializer.validated_data.get('preprocessor_path')
            try:
                # Create the Preprocessor
                preprocessor = Preprocessor(preprocessor_name, preprocessor_type, params=params, preprocessor_path=preprocessor_path)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                output_channel = request.query_params.get('output', None)
                response_data = preprocessor(output_channel, return_serialized=return_serialized)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request):
        serializer = PreprocessorSerializer(data=request.data)
        if serializer.is_valid():
            # Extract data from the serializer
            preprocessor_name = serializer.validated_data.get('preprocessor_name')
            preprocessor_type = serializer.validated_data.get('preprocessor_type')
            params = serializer.validated_data.get('params')
            preprocessor_path = serializer.validated_data.get('preprocessor_path')
            # Create Model instance using the data
            preprocessor = Preprocessor(preprocessor_name, preprocessor_type, params=params, preprocessor_path=preprocessor_path)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, preprocessor(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class FitPreprocessorAPIView(APIView, NodeQueryMixin):
    """
    API view for fitting a preprocessor on the given data.
    """

    def post(self, request, *args, **kwargs):
        serializer = FitPreprocessorSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            preprocessor = serializer.validated_data.get('preprocessor')
            preprocessor_path = serializer.validated_data.get('preprocessor_path')
            try:
                # Create a Fit instance
                fit_instance = FitPreprocessor(data=data, preprocessor=preprocessor, preprocessor_path=preprocessor_path)
                output_channel = request.query_params.get('output', None)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                response_data = fit_instance(output_channel, return_serialized=return_serialized)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = FitPreprocessorSerializer(data=request.data)
        if serializer.is_valid():
            # Extract data from the serializer
            data = serializer.validated_data.get('data')
            preprocessor = serializer.validated_data.get('preprocessor')
            preprocessor_path = serializer.validated_data.get('preprocessor_path')

            # Instantiate Fit and perform the fitting
            fitter = FitPreprocessor(data=data, preprocessor=preprocessor, preprocessor_path=preprocessor_path)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, fitter(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class TransformAPIView(APIView, NodeQueryMixin):
    """
    API view for transforming data using the given preprocessor.
    """

    def post(self, request, *args, **kwargs):
        # Deserialize input data using the serializer
        serializer = TransformSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            preprocessor = serializer.validated_data.get('preprocessor')  # Extract preprocessor (as JSON object)
            preprocessor_path = serializer.validated_data.get('preprocessor_path')  # Extract preprocessor path
            try:
                # Create a Transform instance and get the result
                transform_instance = Transform(data=data, preprocessor=preprocessor, preprocessor_path=preprocessor_path)
                output_channel = request.query_params.get('output', None)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                response_data = transform_instance(output_channel, return_serialized=return_serialized)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

    def put(self, request):
        serializer = TransformSerializer(data=request.data)
        if serializer.is_valid():
            # Extract validated data
            data = serializer.validated_data.get('data')
            preprocessor = serializer.validated_data.get('preprocessor')
            preprocessor_path = serializer.validated_data.get('preprocessor_path')
            
            # Create Transform instance
            transform_instance = Transform(data=data, preprocessor=preprocessor, preprocessor_path=preprocessor_path)
            
            # Get node_id from query parameters
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            # Update the node using NodeUpdater
            success, message = NodeUpdater()(node_id, transform_instance(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class FitTransformAPIView(APIView, NodeQueryMixin):
    """
    API view for fitting and transforming data using the given preprocessor.
    """

    def post(self, request, *args, **kwargs):
        # Deserialize input data using the serializer
        serializer = FitTransformSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            preprocessor = serializer.validated_data.get('preprocessor')  # Extract preprocessor (as JSON object or path)
            preprocessor_path = serializer.validated_data.get('preprocessor_path')  # Extract preprocessor path
            try:
                # Create a FitTransform instance and get the result
                fit_transform_instance = FitTransform(data=data, preprocessor=preprocessor, preprocessor_path=preprocessor_path)
                output_channel = request.query_params.get('output', None)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                response_data = fit_transform_instance(output_channel, return_serialized=return_serialized)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = FitTransformSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            preprocessor = serializer.validated_data.get('preprocessor')
            preprocessor_path = serializer.validated_data.get('preprocessor_path')
            
            fit_transform_instance = FitTransform(data=data, preprocessor=preprocessor, preprocessor_path=preprocessor_path)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, fit_transform_instance(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id, is_special_case=True)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class SplitterAPIView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = SplitterSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            # Initialize and use the Splitter class
            splitter_instance = Splitter(data)
            output_channel = request.query_params.get('output', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            response_data = splitter_instance(output_channel, return_serialized=return_serialized)
            
            return Response(response_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = SplitterSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            splitter_instance = Splitter(data)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, splitter_instance(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id, is_multi_channel=True)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class JoinerAPIView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = JoinerSerializer(data=request.data)
        if serializer.is_valid():
            data_1 = serializer.validated_data.get('data_1')
            data_2 = serializer.validated_data.get('data_2')
            joiner = Joiner(data_1, data_2)
            output_channel = request.query_params.get('output', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            response_data = joiner(output_channel, return_serialized=return_serialized)
            return Response(response_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = JoinerSerializer(data=request.data)
        if serializer.is_valid():
            data_1 = serializer.validated_data.get('data_1')
            data_2 = serializer.validated_data.get('data_2')
            joiner = Joiner(data_1, data_2)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, joiner(), return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class TrainTestSplitAPIView(APIView, NodeQueryMixin):
    def post(self, request, *args, **kwargs):
        serializer = TrainTestSplitSerializer(data=request.data)
        if serializer.is_valid():
            try:
                # Extract validated data
                data = serializer.validated_data.get('data')
                params = serializer.validated_data.get('params')

                # Instantiate TrainTestSplit and perform the split
                splitter = TrainTestSplit(data=data,params=params)
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                output_channel = request.query_params.get('output', None)
                response_data = splitter(output_channel, return_serialized=return_serialized)

                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = TrainTestSplitSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data.get('data')
            params = serializer.validated_data.get('params')
            splitter = TrainTestSplit(data=data, params=params)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, splitter(), return_serialized=return_serialized) 
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id, is_multi_channel=True)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class DataLoaderAPIView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = DataLoaderSerializer(data=request.data)
        if serializer.is_valid():
            dataset_name = serializer.validated_data.get('dataset_name')
            dataset_path = serializer.validated_data.get('dataset_path')
            loader = DataLoader(dataset_name=dataset_name, dataset_path=dataset_path)
            output_channel = request.query_params.get('output', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            response_data = loader(output_channel, return_serialized=return_serialized)
            
            return Response(response_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = DataLoaderSerializer(data=request.data)
        if serializer.is_valid():
            dataset_name = serializer.validated_data.get('dataset_name')
            dataset_path = serializer.validated_data.get('dataset_path')
            loader = DataLoader(dataset_name=dataset_name, dataset_path=dataset_path)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, loader(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id, is_multi_channel=True)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class EvaluatorAPIView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = EvaluatorSerializer(data=request.data)
        if serializer.is_valid():
            y_true = serializer.validated_data.get('y_true')
            y_pred = serializer.validated_data.get('y_pred')
            params = serializer.validated_data.get('params')
            metric = params.get('metric')

            evaluator = Evaluator(metric=metric, y_true=y_true, y_pred=y_pred)
            output_channel = request.query_params.get('output', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            response_data = evaluator(output_channel, return_serialized=return_serialized)
            return Response(response_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = EvaluatorSerializer(data=request.data)
        if serializer.is_valid():
            y_true = serializer.validated_data.get('y_true')
            y_pred = serializer.validated_data.get('y_pred')
            params = serializer.validated_data.get('params')
            metric = params.get('metric')
            evaluator = Evaluator(metric=metric, y_true=y_true, y_pred=y_pred)
            node_id = request.query_params.get('node_id', None)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            success, message = NodeUpdater()(node_id, evaluator(), return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class NodeLoaderAPIView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            try:
                node_id = serializer.validated_data.get('node_id')
                path = serializer.validated_data.get('node_path')
                loader = NodeLoader()
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                payload = loader(node_id=node_id, path=path)
                NodeSaver()(payload)
                payload = NodeLoader()(node_id=payload.get("node_id"), from_db=True, return_serialized=return_serialized)
                if not return_serialized:
                    del payload["node_data"]
                return Response(payload, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
    def put(self, request):
        serializer = NodeLoaderSerializer(data=request.data)
        if serializer.is_valid():
            node_id = serializer.validated_data.get('node_id')
            path = serializer.validated_data.get('node_path')
            loader = NodeLoader()
            payload = loader(node_id=node_id, path=path)
            NodeSaver()(payload)
            return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            payload = NodeLoader()(node_id=payload.get("node_id"), from_db=True)
            node_id = request.query_params.get('node_id', None)
            success, message = NodeUpdater()(node_id, payload, return_serialized=return_serialized)
            if not return_serialized:
                    del message["node_data"]
            if success:
                return Response({"message": message}, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        

class NodeSaveAPIView(APIView, NodeQueryMixin):
    def post(self, request):
        serializer = NodeSaverSerializer(data=request.data)
        if serializer.is_valid():
            try:
                payload = request.data.get("node")
                path = request.data.get("node_path")  # Optional path parameter
                saver = NodeSaver()
                node_data = NodeLoader()(node_id=payload.get("node_id")).get('node_data')
                payload['node_data'] = node_data
                payload.update({"node_id": id(saver)})
                return_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
                res = saver(payload, path=path)
                response = saver(res)
                if return_serialized:
                    node_data = NodeLoader()(node_id=response.get("node_id"), return_serialized=True).get("node_data")
                    response["node_data"] = node_data
                return Response(response, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
            except Exception as e:
                return Response({"error": f"Internal error: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def put(self, request):
        serializer = NodeSaverSerializer(data=request.data)
        if serializer.is_valid():
            payload = request.data.get("node")
            path = request.data.get("node_path")
            saver = NodeSaver()
            node_data = NodeLoader()(node_id=payload.get("node_id")).get('node_data')
            payload['node_data'] = node_data
            payload.update({"node_id": id(saver)})
            returned_serialized = True if request.query_params.get('return_serialized', None) == '1' else False
            res = saver(payload, path=path)
            response = saver(res)
            node_id = request.query_params.get('node_id', None)
            success, message = NodeUpdater()(node_id, response,return_serialized=returned_serialized)
            if returned_serialized:
                    message['node_data'] = NodeLoader()(message.get('node_id'), return_serialized=True).get('node_data')
            if success:
                return Response(message, status=status.HTTP_200_OK)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        node_id = request.query_params.get('node_id')
        if not node_id:
            return Response({"error": "Node ID is required"}, status=status.HTTP_400_BAD_REQUEST)
        try:
            success, message = NodeDeleter()(node_id)
            if success:
                return Response({"message": f"Node {node_id} deleted successfully."},
                    status=status.HTTP_204_NO_CONTENT)
            else:
                return Response({"error": message}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ComponentAPIViewSet(viewsets.ModelViewSet):
    queryset = Component.objects.all()
    serializer_class = ComponentSerializer


class ClearNodesAPIView(APIView):
    def post(self, request):
        try:
            response = ClearAllNodes()()
            return Response(response, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ClearComponentsAPIView(APIView):
    def post(self, request):
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
