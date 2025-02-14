# api/serializers.py
from rest_framework import serializers
from .models import Component


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
        return validate(data, ('model_name', 'model_path'))


class FitModelSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    y = serializers.JSONField(required=True)
    model_path = serializers.CharField(required=False)
    model = serializers.JSONField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, ('model', 'model_path'))


class PredictSerializer(serializers.Serializer):
    X = serializers.JSONField(required=True)
    model = serializers.JSONField(required=False)
    model_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'model' or 'model_path' is provided.
        """
        return validate(data, ('model', 'model_path'))


class PreprocessorSerializer(serializers.Serializer):
    preprocessor_name = serializers.CharField(required=False)  # Add all supported scalers
    preprocessor_type = serializers.ChoiceField(choices=['scaler', 'encoding', 'imputation', 'binarization'], required=False)
    params = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, ('preprocessor_name', 'preprocessor_path'))


class FitPreprocessorSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, ('preprocessor', 'preprocessor_path'))


class TransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, ('preprocessor', 'preprocessor_path'))


class FitTransformSerializer(serializers.Serializer):
    data = serializers.JSONField(required=True)
    preprocessor = serializers.JSONField(required=False)
    preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'preprocessor' or 'preprocessor_path' is provided.
        """
        return validate(data, ('preprocessor', 'preprocessor_path'))


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


class NodeLoaderSerializer(serializers.Serializer):
    node_id = serializers.IntegerField(required=False)
    path = serializers.CharField(required=False)
    def validate(self, data):
        """
        Ensure at least one of 'node_name' or 'node_path' is provided.
        """
        return validate(data, ('node_id', 'path'))
    
class NodeSaverSerializer(serializers.Serializer):
    node = serializers.JSONField(required=True)
    path = serializers.CharField(required=True)
    

class EvaluatorSerializer(serializers.Serializer):
    metric = serializers.CharField(required=True)
    y_true = serializers.JSONField(required=True)
    y_pred = serializers.JSONField(required=True)
    params = serializers.JSONField(required=False)


class ComponentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Component
        fields = '__all__'
        extra_kwargs = {
            'params': {'allow_null': True},
            'input_dots': {'allow_null': True},
            'output_dots': {'allow_null': True}
        }


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
