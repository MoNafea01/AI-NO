# api/serializers.py
from rest_framework import serializers
from .models import Component, Node, Project
import base64
import time

class JSONOrIntField(serializers.Field):
    def to_internal_value(self, data):
        """Convert input data to a Python native datatype."""
        if isinstance(data, (dict, list, int, str)):  # Allow JSON (dict/list) and int
            return data
        raise serializers.ValidationError("This field must be a JSON object or an integer.")

    def to_representation(self, value):
        """Convert Python object back to a JSON-serializable format."""
        return value  # Return as-is (int or JSON)


class DataLoaderSerializer(serializers.Serializer):
    params = serializers.JSONField(required=True)


class TrainTestSplitSerializer(serializers.Serializer):
    X = JSONOrIntField(required=False)
    y = JSONOrIntField(required=False)
    params = serializers.JSONField(required=False)
    def validate(self, data):
        return validate(data, (('X', 'y'), 'X', 'y'))


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
    fitted_model = JSONOrIntField(required=False)
    fitted_model_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('fitted_model', 'X'), 'fitted_model_path'))


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
    fitted_preprocessor = JSONOrIntField(required=False)
    fitted_preprocessor_path = serializers.CharField(required=False)
    def validate(self, data):
        return validate(data, (('fitted_preprocessor', 'data'), 'fitted_preprocessor_path'))


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


class ModelCompilerSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, default={})
    nn_model = JSONOrIntField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data):
        return validate(data, (('nn_model', 'params'), 'path'))


class NetModelFitterSerializer(serializers.Serializer):
    params = serializers.JSONField(required=False, default={})
    compiled_model = JSONOrIntField(required=False)
    X = JSONOrIntField(required=False)
    y = JSONOrIntField(required=False)
    name = serializers.CharField(required=False)
    path = serializers.CharField(required=False, allow_null=True)
    def validate(self, data):
        return validate(data, (('compiled_model', 'params', 'X', 'y'), 'path'))


class NodeLoaderSerializer(serializers.Serializer):
    params = serializers.JSONField(required=True)


class NodeSaverSerializer(serializers.Serializer):
    node = JSONOrIntField(required=True)
    params = serializers.JSONField(required=True)


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
        # node_data_base64 = validated_data.pop("node_data", None)
        # if node_data_base64 :
        #     validated_data["node_data"] = base64.b64decode(node_data_base64)

        project_id = validated_data.pop("project_id")
        if project_id:
            try:
                project = Project.objects.get(id=project_id)
                validated_data["project_id"] = project.id
            except Project.DoesNotExist:
                raise serializers.ValidationError(f"Project with id {project_id} does not exist")
        
        # Generate a unique node_id if not provided
        if 'node_id' not in validated_data:
            validated_data["node_id"] = int(time.time() * 1000)
                
        return super().create(validated_data)
    
    def update(self, instance, validated_data):
        """Handle node updates, including location and ports"""
        
        # Handle node_data if provided
        # node_data_base64 = validated_data.pop("node_data", None)
        # if node_data_base64:
        #     validated_data["node_data"] = base64.b64decode(node_data_base64)
        
        # Handle project_id if provided
        project_id = validated_data.pop("project_id")
        if project_id:
            try:
                project = Project.objects.get(id=project_id)
                validated_data["project_id"] = project.id
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
        return_serialized = self.context.get('return_serialized', False)
        if return_serialized:
            if hasattr(instance, 'node_data') and instance.node_data:
                with open(instance.node_data, 'rb') as f:
                    node_data = f.read()
                representation["node_data"] = base64.b64encode(node_data).decode()    
        else:
            representation["node_data"] = instance.node_data if isinstance(instance.node_data, str) else None     
            
        representation.pop('created_at', None)
        representation.pop('updated_at', None)

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
    key3 = ' and '.join(keys[2]) if len(keys) > 2 else None
    if key3:
        raise serializers.ValidationError(f"You must provide {key1} - or - {key2} - or - {key3}.")
    else:
        raise serializers.ValidationError(f"You must provide {key1} - or - {key2}.")


class ExportProjectSerializer(serializers.Serializer):
    folder_path = serializers.CharField(required=False, allow_blank=True, help_text="File path to save the exported file")
    format = serializers.ChoiceField(required=False, choices=['json', 'ainoprj'], help_text="Export format (json or ainoprj)")
    file_name = serializers.CharField(required=False, allow_blank=True, help_text="File name for the exported file")
    password = serializers.CharField(required=False, allow_blank=True, help_text="Password for encrypted AINOPRJ files")    

class ImportProjectSerializer(serializers.Serializer):
    path = serializers.CharField(required=True, help_text="File path to the project file to import")
    format = serializers.ChoiceField(required=False, default='auto', choices=['auto', 'json', 'ainoprj'], 
                                   help_text="Format of the import file (auto will detect based on extension)")
    password = serializers.CharField(required=False, allow_blank=True, 
                                   help_text="Password for encrypted AINOPRJ files")
    project_name = serializers.CharField(required=False, allow_blank=True, help_text="Name for the imported project")
    project_description = serializers.CharField(required=False, allow_blank=True, help_text="Description for the imported project")
