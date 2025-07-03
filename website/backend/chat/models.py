from django.db import models
from django.conf import settings



class Room(models.Model):
    room_name = models.CharField(max_length=255)
    def __str__(self):
        return f'{self.room_name}'


class Message(models.Model):
    room_name = models.ForeignKey(Room, on_delete=models.CASCADE)
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f'{self.sender.username} in {self.room_name}: {self.content[:20]}'



