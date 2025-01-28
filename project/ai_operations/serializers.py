# api/serializers.py
from rest_framework import serializers
from .models import Workflow, Node

class NodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Node
        fields = '__all__'

class WorkflowSerializer(serializers.ModelSerializer):
    nodes = NodeSerializer(many=True)

    class Meta:
        model = Workflow
        fields = ['id', 'name', 'description', 'nodes']

class ModelSerializer(serializers.Serializer):
    model_name = serializers.CharField(max_length=100, required=False)
    model_type = serializers.CharField(max_length=100, required=False)
    task = serializers.CharField(max_length=100, required=False)
    params = serializers.JSONField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data:dict):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, 'model_name', 'model_path')


class FitModelSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    y = serializers.JSONField(required=True)
    model_path = serializers.CharField(required=False)
    model = serializers.JSONField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, 'model', 'model_path')

class PredictSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    model = serializers.JSONField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, 'model', 'model_path')
    
class PreprocessorSerializer(serializers.Serializer):
    preprocessor_name = serializers.CharField(required=False)  # Add all supported scalers
    preprocessor_type = serializers.ChoiceField(choices=['scaler', 'encoding', 'imputation', 'binarization'], required=False)
    params = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, 'preprocessor_name', 'preprocessor_path')

class FitPreprocessorSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=True)

class TransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=True)

class FitTransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=True)
    
class SplitterSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)

class TrainTestSplitSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    params = serializers.JSONField(required=False)

class DataLoaderSerializer(serializers.Serializer):
    data_type = serializers.CharField(required=False)
    filepath = serializers.CharField(required=False)

def validate(data, *args:str):
    for arg in args:
        val = data.get(arg)
        if val:
            return data
    raise serializers.ValidationError(
        f"You must provide either {', '.join(args)}."
    )
