from django.shortcuts import render

# Create your views here.
# api/views.py
from rest_framework import viewsets
from rest_framework.response import Response
from .models import Workflow
from rest_framework.decorators import action, api_view
from rest_framework.views import APIView, Response
from rest_framework import status
from core.nodes import DataLoader
from core.nodes.model.model import Model
from core.nodes.model.fit import Fit as FitModel
from core.nodes.model.predict import Predict
from core.nodes.preprocessing.preprocessor import Preprocessor
from core.nodes.preprocessing.transform import Transform
from core.nodes.preprocessing.train_test_split import TrainTestSplit
from core.nodes.preprocessing.splitter import Splitter
from core.nodes.preprocessing.fit_transform import FitTransform
from core.nodes.preprocessing.fit import Fit as FitPreprocessor
from core.nodes.metrics import Evaluator
from .serializers import WorkflowSerializer, ModelSerializer, FitModelSerializer, PredictSerializer, PreprocessorSerializer
from .serializers import FitPreprocessorSerializer, TransformSerializer, FitTransformSerializer, TrainTestSplitSerializer
from .serializers import SplitterSerializer, DataLoaderSerializer


class WorkflowViewSet(viewsets.ModelViewSet):
    queryset = Workflow.objects.all()
    serializer_class = WorkflowSerializer

    @action(detail=True, methods=['post'])
    def execute(self, request, pk=None):
        workflow = self.get_object()
        nodes = workflow.nodes.order_by('order')

        # Here, execute the nodes sequentially
        result = self.execute_workflow(nodes)
        return Response({"result": result}, status=status.HTTP_200_OK)

    def execute_workflow(self,nodes):
        # Load data
        for node in nodes:
            if node.node_type == "dataLoader":
                loader = DataLoader(**node.config)
                X, y = loader.load()

            elif node.node_type == "splitter":
                splitter = TrainTestSplit(**node.config).payload.values()
                (X_train, X_test), (y_train, y_test) = splitter

            elif node.node_type == "preprocessor":
                preprocessor = Preprocessor(**node.config)
            
            elif node.node_type == "fit_transform":
                X_train = FitTransform(X_train, preprocessor).payload['transformed_data']
            elif node.node_type == "transform":
                X_test = Transform(X_test, preprocessor).payload['transformed_data']
            elif node.node_type == "model":
                model = Model(**node.config)
            elif node.node_type == "fit":
                FitModel(X_train, y_train, model)
            elif node.node_type == "predict":
                y_pred = Predict(X_test, model).payload['predictions']
            elif node.node_type == "evaluator":
                evaluator = Evaluator(**node.config)
                score = evaluator.evaluate(y_test, y_pred)
        return score

class CreateModelView(APIView):
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
                params=data.get('params')
            )
            output_channel = request.query_params.get('output', None)
            response_data = model_instance(output_channel)
            return Response(response_data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class FitModelAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = FitModelSerializer(data=request.data)
        if serializer.is_valid():
            try:
                # Extract validated data
                X = serializer.validated_data.get('X')
                y = serializer.validated_data.get('y')
                model = serializer.validated_data.get('model')

                # Instantiate Fit and perform the fitting
                fitter = FitModel(X=X, y=y, model=model)
                payload = fitter.payload

                return Response(payload, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PredictAPIView(APIView):
    """
    API view to handle predictions using a trained model.
    """

    def post(self, request, *args, **kwargs):
        serializer = PredictSerializer(data=request.data)
        if serializer.is_valid():
            X = serializer.validated_data['X']
            model = serializer.validated_data['model']

            try:
                # Perform prediction
                predictor = Predict(X, model=model)
                output_channel = request.query_params.get('output', None)
                response_data = predictor(output_channel)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PreprocessorAPIView(APIView):
    """
    API view to create a Preprocessor instance.
    """

    def post(self, request, *args, **kwargs):
        serializer = PreprocessorSerializer(data=request.data)
        if serializer.is_valid():
            preprocessor_name = serializer.validated_data['preprocessor_name']
            preprocessor_type = serializer.validated_data['preprocessor_type']
            params = serializer.validated_data.get('params')

            try:
                # Create the Preprocessor
                preprocessor = Preprocessor(preprocessor_name, preprocessor_type, params=params)
                output_channel = request.query_params.get('output', None)
                response_data = preprocessor(output_channel)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
class FitPreprocessorAPIView(APIView):
    """
    API view for fitting a preprocessor on the given data.
    """

    def post(self, request, *args, **kwargs):
        serializer = FitPreprocessorSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data['data']
            preprocessor = serializer.validated_data.get('preprocessor')

            try:
                # Create a Fit instance
                fit_instance = FitPreprocessor(data=data, preprocessor=preprocessor)
                output_channel = request.query_params.get('output', None)
                response_data = fit_instance(output_channel)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class TransformAPIView(APIView):
    """
    API view for transforming data using the given preprocessor.
    """

    def post(self, request, *args, **kwargs):
        # Deserialize input data using the serializer
        serializer = TransformSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data['data']
            preprocessor = serializer.validated_data.get('preprocessor')  # Extract preprocessor (as JSON object)

            try:
                # Create a Transform instance and get the result
                transform_instance = Transform(data=data, preprocessor=preprocessor)
                output_channel = request.query_params.get('output', None)
                response_data = transform_instance(output_channel)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class FitTransformAPIView(APIView):
    """
    API view for fitting and transforming data using the given preprocessor.
    """

    def post(self, request, *args, **kwargs):
        # Deserialize input data using the serializer
        serializer = FitTransformSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data['data']
            preprocessor = serializer.validated_data.get('preprocessor')  # Extract preprocessor (as JSON object or path)

            try:
                # Create a FitTransform instance and get the result
                fit_transform_instance = FitTransform(data=data, preprocessor=preprocessor)
                output_channel = request.query_params.get('output', None)
                response_data = fit_transform_instance(output_channel)
                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class SplitterAPIView(APIView):
    def post(self, request):
        serializer = SplitterSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data['data']
            # Initialize and use the Splitter class
            splitter_instance = Splitter(data)
            output_channel = request.query_params.get('output', None)
            response_data = splitter_instance(output_channel)
            
            return Response(response_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class TrainTestSplitAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = TrainTestSplitSerializer(data=request.data)
        if serializer.is_valid():
            try:
                # Extract validated data
                data = serializer.validated_data.get('data')
                params = data.get('params')

                # Instantiate TrainTestSplit and perform the split
                splitter = TrainTestSplit(data=data,params=params)
                output_channel = request.query_params.get('output', None)
                response_data = splitter(output_channel)

                return Response(response_data, status=status.HTTP_200_OK)
            except ValueError as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class DataLoaderAPIView(APIView):
    def post(self, request):
        serializer = DataLoaderSerializer(data=request.data)
        if serializer.is_valid():
            data_type = serializer.validated_data.get('data_type')
            filepath = serializer.validated_data.get('filepath')
            loader = DataLoader(data_type=data_type, filepath=filepath)
            output_channel = request.query_params.get('output', None)
            response_data = loader(output_channel)
            
            return Response(response_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)