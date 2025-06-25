from django.db import models


class Project(models.Model):
    project_name = models.CharField(max_length=255)
    project_description = models.TextField()
    model = models.CharField(max_length=255, null=True, blank=True)
    dataset = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.project_name


class Node(models.Model):
    id = models.AutoField(primary_key=True)
    node_id = models.BigIntegerField()
    displayed_name = models.CharField(max_length=255, default="")
    node_name = models.CharField(max_length=255)
    message = models.CharField(max_length=255, default="Done")
    node_data = models.CharField(max_length=500, null=True, blank=True)
    params = models.JSONField(default=dict)
    task = models.CharField(max_length=255,default='general')
    node_type = models.CharField(max_length=255, default="general")
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='nodes', null=True, blank=True)
    uid = models.BigIntegerField(null=True, blank=True)
    children = models.JSONField(null=True, blank=True, default=list)
    parent = models.JSONField(null=True, blank=True, default=list)
    location_x = models.FloatField(default=0.0)
    location_y = models.FloatField(default=0.0)
    input_ports = models.JSONField(default=list)  # List of node_ids for input connections
    output_ports = models.JSONField(default=list)  # List of node_ids for output connections
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    class Meta:
        unique_together = ('project', 'node_id')

    def __str__(self):
        return f"{self.node_name} ({self.node_id})"


class Component(models.Model):
    uid = models.BigIntegerField(primary_key=True)
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

