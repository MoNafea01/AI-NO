# api/serializers.py
from rest_framework import serializers
from .models import Component, Node
import base64


class DataLoaderSerializer(serializers.Serializer):
    dataset_name = serializers.CharField(required=False)
    dataset_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'dataset_name' or 'dataset_path' is provided.
        """
        return validate(data, ('dataset_name', 'dataset_path'))


class TrainTestSplitSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    params = serializers.JSONField(required=False)


class SplitterSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)


class JoinerSerializer(serializers.Serializer):
    data_1 = serializers.JSONField(required=True)
    data_2 = serializers.JSONField(required=True)


class ModelSerializer(serializers.Serializer):
    model_name = serializers.CharField(max_length=100, required=False)
    model_type = serializers.CharField(max_length=100, required=False)
    task = serializers.CharField(max_length=100, required=False)
    params = serializers.JSONField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data:dict):
        """
        Ensure at least one of 'model_name' or 'model_path' is provided.
        """
        return validate(data, (('model_name', 'model_type', 'task'), 'model_path'))


class FitModelSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    y = serializers.JSONField(required=True)
    model_path = serializers.CharField(required=False)
    model = serializers.JSONField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, (('model', 'X', 'y'), 'model_path'))


class PredictSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    model = serializers.JSONField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, (('model', 'X'), 'model_path'))


class EvaluatorSerializer(serializers.Serializer):
    metric = serializers.CharField(required=True)
    y_true = serializers.JSONField(required=True)
    y_pred = serializers.JSONField(required=True)


class PreprocessorSerializer(serializers.Serializer):
    preprocessor_name = serializers.CharField(required=False)  # Add all supported scalers
    preprocessor_type = serializers.ChoiceField(choices=['scaler', 'encoder', 'imputer', 'binarizer'], required=False)
    params = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, (('preprocessor_name', 'preprocessor_type'), 'preprocessor_path'))


class FitPreprocessorSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, (('preprocessor', 'data'), 'preprocessor_path'))


class TransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, (('preprocessor', 'data'), 'preprocessor_path'))


class FitTransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, (('preprocessor', 'data'), 'preprocessor_path'))


class InputSerializer(serializers.Serializer):
    shape = serializers.JSONField(required=False, allow_null=True)
    name = serializers.CharField(required=False, allow_null=True)
    input_path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'input_path' is provided.
        """
        return validate(data, ('shape', 'input_path'))


class DenseSerializer(serializers.Serializer):
    units = serializers.IntegerField(required=False, default=1)
    activation = serializers.CharField(required=False, default='relu')
    prev_node = serializers.JSONField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'path' is provided.
        """
        return validate(data, ('units', 'path'))


class FlattenSerializer(serializers.Serializer):
    prev_node = serializers.JSONField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'path' is provided.
        """
        return validate(data, ('prev_node', 'path'))


class DropoutSerializer(serializers.Serializer):
    rate = serializers.FloatField(required=False, default=0.5)
    prev_node = serializers.JSONField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'path' is provided.
        """
        return validate(data, (('prev_node', 'rate'), 'path'))


class Conv2DSerializer(serializers.Serializer):
    filters = serializers.IntegerField(required=False, default=32)
    kernel_size = serializers.JSONField(required=False, default=[3, 3])
    strides = serializers.JSONField(required=False, default=[1, 1])
    padding = serializers.CharField(required=False, default='valid')
    activation = serializers.CharField(required=False, default='relu')
    prev_node = serializers.JSONField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'path' is provided.
        """
        return validate(data, (('filters', 'kernel_size'), 'path'))


class MaxPool2DSerializer(serializers.Serializer):
    pool_size = serializers.JSONField(required=False, default=[2, 2])
    strides = serializers.JSONField(required=False, default=[2, 2])
    padding = serializers.CharField(required=False, default='valid')
    prev_node = serializers.JSONField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'path' is provided.
        """
        return validate(data, ('prev_node', 'path'))


class SequentialSerializer(serializers.Serializer):
    layer = serializers.JSONField()
    name = serializers.JSONField(required=False)
    path = serializers.CharField(required=False)
    def validate(self, data:dict):
        """
        Ensure at least one of 'name' or 'path' is provided.
        """
        return validate(data, ('layer', 'path'))


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
