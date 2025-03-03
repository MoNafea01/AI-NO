# api/serializers.py
from rest_framework import serializers
from .models import Component, Node
import base64


class ModelSerializer(serializers.Serializer):
    node_name = serializers.CharField(max_length=100, required=False)
    node_type = serializers.CharField(max_length=100, required=False)
    task = serializers.CharField(max_length=100, required=False)
    params = serializers.JSONField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data:dict):
        """
        Ensure at least one of 'node_name' or 'node_path' is provided.
        """
        return validate(data, ('node_name', 'node_path'))


class FitModelSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    y = serializers.JSONField(required=True)
    node_path = serializers.CharField(required=False)
    node = serializers.JSONField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node' or 'node_path' is provided.
        """
        return validate(data, ('node', 'node_path'))


class PredictSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    node = serializers.JSONField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node' or 'node_path' is provided.
        """
        return validate(data, ('node', 'node_path'))


class PreprocessorSerializer(serializers.Serializer):
    node_name = serializers.CharField(required=False)  # Add all supported scalers
    node_type = serializers.ChoiceField(choices=['scaler', 'encoder', 'imputer', 'binarizer'], required=False)
    params = serializers.JSONField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node' or 'node_path' is provided.
        """
        return validate(data, ('node_name', 'node_path'))


class FitPreprocessorSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    node = serializers.JSONField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node' or 'node_path' is provided.
        """
        return validate(data, ('node', 'node_path'))


class TransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    node = serializers.JSONField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node' or 'node_path' is provided.
        """
        return validate(data, ('node', 'node_path'))


class FitTransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    node = serializers.JSONField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node' or 'node_path' is provided.
        """
        return validate(data, ('node', 'node_path'))


class SplitterSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)


class JoinerSerializer(serializers.Serializer):
    data_1 = serializers.JSONField(required=True)
    data_2 = serializers.JSONField(required=True)


class TrainTestSplitSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    params = serializers.JSONField(required=False)


class DataLoaderSerializer(serializers.Serializer):
    dataset_name = serializers.CharField(required=False)
    dataset_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'dataset_name' or 'dataset_path' is provided.
        """
        return validate(data, ('dataset_name', 'dataset_path'))


class EvaluatorSerializer(serializers.Serializer):
    metric = serializers.CharField(required=True)
    y_true = serializers.JSONField(required=True)
    y_pred = serializers.JSONField(required=True)
    params = serializers.JSONField(required=False)


class NodeLoaderSerializer(serializers.Serializer):
    node_id = serializers.IntegerField(required=False)
    node_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node_name' or 'node_path' is provided.
        """
        return validate(data, ('node_id', 'node_path'))


class NodeSaverSerializer(serializers.Serializer):
    node = serializers.JSONField(required=True)
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
    class Meta:
        model = Node
        fields = '__all__'
        extra_kwargs = {
            'params': {'allow_null': True},
        }
    def create(self, validated_data):
        """Decode Base64-encoded node_data before saving"""
        node_data_base64 = validated_data.pop('node_data', None)
        if node_data_base64:
            validated_data['node_data'] = base64.b64decode(node_data_base64)
        return super().create(validated_data)
    
    def to_representation(self, instance):
        """Customize serialization to convert binary data to Base64"""
        representation = super().to_representation(instance)
        if instance.node_data:
            representation['node_data'] = base64.b64encode(instance.node_data).decode()

        return representation


def validate(data, *args:tuple):
    missing = []
    for group in args:
        if not isinstance(group, tuple):
            raise ValueError("Arguments must be tuples.")
        if not any(key in data for key in group):
            missing.append(f"either {', '.join(group)}")
    if missing:
        raise serializers.ValidationError(
            f"You must provide {' and '.join(missing)}."
        )
    return data
