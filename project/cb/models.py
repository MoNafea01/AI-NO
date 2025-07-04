from django.db import models

class ChatBotHistory(models.Model):
    project_id = models.CharField(max_length=100)
    history = models.JSONField(default=list)

    def __str__(self):
        return f"History for Project {self.project_id}"
    
    class Meta:
        app_label = 'cb'
