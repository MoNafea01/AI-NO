from django.db import models


class Workflow(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Node(models.Model):
    workflow = models.ForeignKey(Workflow, related_name='nodes', on_delete=models.CASCADE)
    node_type = models.CharField(max_length=255)  # e.g., 'dataLoader', 'preprocessor', 'modelTrainer', etc.
    config = models.JSONField()  # Store the configuration as a JSON
    order = models.IntegerField()  # Order of execution

class NodeStorage(models.Model):
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