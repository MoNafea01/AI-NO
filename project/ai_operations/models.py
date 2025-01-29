from django.db import models
from django.utils import timezone

class Node(models.Model):
    node_id = models.IntegerField(primary_key=True)
    node_name = models.CharField(max_length=255)
    message = models.CharField(max_length=255, default="Done")
    node_data = models.BinaryField()
    params = models.JSONField(default=dict)
    task = models.CharField(max_length=255,default='general')
    node_type = models.CharField(max_length=255, default="general")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    def __str__(self):
        return f"{self.node_name} ({self.node_id})"

class Component(models.Model):
    node_name = models.CharField(max_length=255)
    node_type = models.CharField(max_length=255, default="general")
    task = models.CharField(max_length=255,default='general')
    params = models.JSONField(null=True, blank=True)  # Changed to core JSONField
    input_dots = models.JSONField(null=True, blank=True)
    output_dots = models.JSONField(null=True, blank=True)
    api_call = models.CharField(max_length=100)