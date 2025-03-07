from django.db import models


# class Project(models.Model):
#     project_name = models.CharField(max_length=255)
#     project_description = models.TextField()
#     created_at = models.DateTimeField(auto_now_add=True)
#     updated_at = models.DateTimeField(auto_now=True)

class Node(models.Model):
    node_id = models.BigIntegerField(primary_key=True)
    node_name = models.CharField(max_length=255)
    message = models.CharField(max_length=255, default="Done")
    node_data = models.BinaryField(null=True, blank=True)
    params = models.JSONField(default=dict)
    task = models.CharField(max_length=255,default='general')
    node_type = models.CharField(max_length=255, default="general")
    # project_id = models.OneToOneField('Project', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    def __str__(self):
        return f"{self.node_name} ({self.node_id})"


class Component(models.Model):
    displayed_name = models.CharField(max_length=255, default="")
    description = models.CharField(max_length=255, default="")
    idx = models.IntegerField(default=0) 
    category = models.CharField(max_length=255, default="")
    node_name = models.CharField(max_length=255)
    node_type = models.CharField(max_length=255, default="general")
    task = models.CharField(max_length=255,default='general')
    params = models.JSONField(null=True, blank=True)
    input_channels = models.JSONField(null=True, blank=True)
    output_channels = models.JSONField(null=True, blank=True)
    api_call = models.CharField(max_length=100)

