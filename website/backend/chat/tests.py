# for testing => python manage.py test chat

from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from .models import Room, Message
from .serializers import MessageSerializer

User = get_user_model()

class ChatAppTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser', email='test@example.com', password='testpass123'
        )
        self.client.force_authenticate(user=self.user)
        self.room = Room.objects.create(room_name='testroom')

    def test_room_list(self):
        response = self.client.get('/chat/rooms/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['room_name'], 'testroom')

    def test_room_messages_empty(self):
        response = self.client.get(f'/chat/messages/{self.room.room_name}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_room_messages_with_data(self):
        Message.objects.create(room_name=self.room, sender=self.user, content='Hello')
        response = self.client.get(f'/chat/messages/{self.room.room_name}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['content'], 'Hello')

    def test_room_not_found(self):
        response = self.client.get('/chat/messages/nonexistent/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(response.data['error'], 'Room not found')

