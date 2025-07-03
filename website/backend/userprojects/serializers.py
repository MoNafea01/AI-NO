from rest_framework import serializers
from .models import PROJECTS

class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = PROJECTS
        fields = '__all__'
        read_only_fields = ['owner', 'uploaded_at']