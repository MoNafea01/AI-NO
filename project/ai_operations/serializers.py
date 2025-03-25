# api/serializers.py
from rest_framework import serializers
from .models import Component, Node, Project
import base64
import time

class JSONOrIntField(serializers.Field):
    def to_internal_value(self, data):
        """Convert input data to a Python native datatype."""
        if isinstance(data, (dict, list, int)):  # Allow JSON (dict/list) and int
            return data
        raise serializers.ValidationError("This field must be a JSON object or an integer.")

    def to_representation(self, value):
        """Convert Python object back to a JSON-serializable format."""
        return value  # Return as-is (int or JSON)


class DataLoaderSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False)
    dataset_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, ('params', 'dataset_path'))


class TrainTestSplitSerializer(serializers.Serializer):
    data = JSONOrIntField(required=True)
    params = serializers.JSONField(required=False)


class SplitterSerializer(serializers.Serializer):
    data = JSONOrIntField(required=True)


class JoinerSerializer(serializers.Serializer):
    data_1 = JSONOrIntField(required=True)
    data_2 = JSONOrIntField(required=True)


class ModelSerializer(serializers.Serializer):
    model_name = serializers.CharField(max_length=100, required=False)
    model_type = serializers.CharField(max_length=100, required=False)
    task = serializers.CharField(max_length=100, required=False)
    params = serializers.JSONField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data:dict):
        return validate(data, (('model_name', 'model_type', 'task'), 'model_path'))


class FitModelSerializer(serializers.Serializer):
    X = JSONOrIntField(required=True)
    y = JSONOrIntField(required=True)
    model_path = serializers.CharField(required=False)
    model = JSONOrIntField(required=False)
    def validate(self, data):
        return validate(data, (('model', 'X', 'y'), 'model_path'))


class PredictSerializer(serializers.Serializer):
    X = JSONOrIntField(required=True)
    model = JSONOrIntField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('model', 'X'), 'model_path'))


class EvaluatorSerializer(serializers.Serializer):
    params = serializers.JSONField(required=True)
    y_true = JSONOrIntField(required=True)
    y_pred = JSONOrIntField(required=True)


class PreprocessorSerializer(serializers.Serializer):
    preprocessor_name = serializers.CharField(required=False)  # Add all supported scalers
    preprocessor_type = serializers.ChoiceField(choices=['scaler', 'encoder', 'imputer', 'binarizer'], required=False)
    params = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('preprocessor_name', 'preprocessor_type'), 'preprocessor_path'))


class FitPreprocessorSerializer(serializers.Serializer):
    data = JSONOrIntField(required=True)
    preprocessor = JSONOrIntField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('preprocessor', 'data'), 'preprocessor_path'))


class TransformSerializer(serializers.Serializer):
    data = JSONOrIntField(required=True)
    preprocessor = JSONOrIntField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('preprocessor', 'data'), 'preprocessor_path'))


class FitTransformSerializer(serializers.Serializer):
    data = JSONOrIntField(required=True)
    preprocessor = JSONOrIntField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('preprocessor', 'data'), 'preprocessor_path'))


class InputSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, allow_null=True)
    name = serializers.CharField(required=False, allow_null=True)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data):
        return validate(data, ('path', 'params'))


class Conv2DSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, allow_null=True)
    prev_node = JSONOrIntField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data):
        return validate(data, (('prev_node', 'params'), 'path'))


class MaxPool2DSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, allow_null=True)
    prev_node = JSONOrIntField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        return validate(data, (('prev_node', 'params'), 'path'))


class FlattenSerializer(serializers.Serializer):
    prev_node = JSONOrIntField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        return validate(data, ('prev_node', 'path'))


class DenseSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, default={})
    prev_node = JSONOrIntField(required=False, default=[])
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        return validate(data, (('prev_node', 'params'), 'path'))


class DropoutSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, default={})
    prev_node = JSONOrIntField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        return validate(data, (('prev_node', 'params'), 'path'))


class SequentialSerializer(serializers.Serializer):
    layer = JSONOrIntField(required=False)
    name = serializers.JSONField(required=False)
    path = serializers.CharField(required=False)
    def validate(self, data:dict):
        return validate(data, ('layer', 'path'))


class NodeLoaderSerializer(serializers.Serializer):
    node_id = serializers.IntegerField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, ("node_id", 'node_path'))


class NodeSaverSerializer(serializers.Serializer):
    node = JSONOrIntField(required=True)
    node_path = serializers.CharField(required=True)


class ComponentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Component
        fields = '__all__'
        extra_kwargs = {
            'params': {'allow_null': True},
            'input_channels': {'allow_null': True},
            'output_channels': {'allow_null': True}
        }


class NodeSerializer(serializers.ModelSerializer):
    node_data = serializers.CharField(write_only=True, required=False)
    project_id = serializers.IntegerField(required=False, write_only=True)
    
    class Meta:
        model = Node
        fields = '__all__'
        extra_kwargs = {
            'params': {'allow_null': True},
            'node_id': {'required': False}  # Make node_id read-only
        }
    
    
    def create(self, validated_data):
        """Decode Base64-encoded node_data before saving and handle project assignment"""
        node_data_base64 = validated_data.pop("node_data", None)
        project_id = validated_data.pop("project_id", None)
        
        if node_data_base64:
            validated_data["node_data"] = base64.b64decode(node_data_base64)
            
        if project_id:
            try:
                project = Project.objects.get(id=project_id)
                validated_data["project"] = project
            except Project.DoesNotExist:
                raise serializers.ValidationError(f"Project with id {project_id} does not exist")
        
        # Generate a unique node_id if not provided
        if 'node_id' not in validated_data:
            validated_data["node_id"] = int(time.time() * 1000)
                
        return super().create(validated_data)
    
    def update(self, instance, validated_data):
        """Handle node updates, including location and ports"""
        
        # Handle node_data if provided
        node_data_base64 = validated_data.pop("node_data", None)
        if node_data_base64:
            validated_data["node_data"] = base64.b64decode(node_data_base64)
        
        # Handle project_id if provided
        project_id = validated_data.pop("project_id", None)
        if project_id:
            try:
                project = Project.objects.get(id=project_id)
                validated_data["project"] = project
            except Project.DoesNotExist:
                raise serializers.ValidationError(f"Project with id {project_id} does not exist")
        
        # Update all fields except node_id
        for attr, value in validated_data.items():
            if attr != 'node_id':  # Skip node_id updates
                setattr(instance, attr, value)
        
        instance.save()
        return instance
    
    def to_representation(self, instance):
        """Customize serialization to convert binary data to Base64"""
        representation = super().to_representation(instance)
        if hasattr(instance, 'node_data') and instance.node_data:
            representation["node_data"] = base64.b64encode(instance.node_data).decode()
            
        representation.pop('created_at', None)
        representation.pop('updated_at', None)

        return_serialized = self.context.get('return_serialized', False)
        if not return_serialized:
            representation.pop('node_data', None) 

        return representation


class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = '__all__'


def validate(data, keys):
    def check_key(key):
        if isinstance(key, str):
            return key in data
        elif isinstance(key, tuple):
            return all(k in data for k in key)
        return False
    
    if not isinstance(keys, tuple):
        raise ValueError("Arguments must be tuples.")
    
    if any(check_key(k) for k in keys):
        return data
    key1 = ' and '.join(keys[0]) if isinstance(keys[0], tuple) else keys[0]
    key2 = ' and '.join(keys[1]) if isinstance(keys[1], tuple) else keys[1]
    raise serializers.ValidationError(f"You must provide {key1} - or - {key2}.")
