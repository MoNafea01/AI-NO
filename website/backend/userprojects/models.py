from django.db import models
from django.conf import settings




# Create your models here.



class PROJECTS(models.Model):
    options = [('private','private') , ('public','public')]
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    option = models.CharField(max_length=50 , null=False, blank=False , choices=options)
    description = models.CharField(max_length=255)
    file = models.FileField(upload_to='projects' , null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"{self.owner}'s project"