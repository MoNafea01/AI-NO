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
        model_path = data.get('model_path')
        if not model_path and not data:
            raise serializers.ValidationError(
                "You must provide either 'model_content' or 'model_path'."
            )
        return data


class FitModelSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    y = serializers.JSONField(required=True)
    model_path = serializers.CharField(required=False)
    model = serializers.JSONField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        model = data.get('model')
        model_path = data.get('model_path')

        if not model and not model_path:
            raise serializers.ValidationError(
                "You must provide either 'model' or 'model_path'."
            )
        return data

class PredictSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    model = serializers.JSONField()

class PreprocessorSerializer(serializers.Serializer):
    preprocessor_name = serializers.CharField(required=True)  # Add all supported scalers
    preprocessor_type = serializers.ChoiceField(choices=['scaler', 'encoding', 'imputation', 'binarization'])
    params = serializers.JSONField(required=False)

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

