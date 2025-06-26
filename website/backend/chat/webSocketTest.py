# pip install pytest pytest-django channels
# for testing => pytest chat/webSocketTest.py --ds=project.settings

import json
import pytest
from channels.testing import WebsocketCommunicator
from django.contrib.auth import get_user_model
from channels.routing import URLRouter
from chat.routing import websocket_urlpatterns
from chat.models import Room
from chat.consumers import ChatConsumer
from accounts.models import Profile
from rest_framework.test import APIClient
from asgiref.sync import sync_to_async

from project.asgi import application  

User = get_user_model()

@pytest.mark.asyncio
@pytest.mark.django_db(transaction=True)
async def test_websocket_chat_message():
    # Create user
    user = await sync_to_async(User.objects.create_user)(
        username='testuser' , email='testuser@test.com', password='testpass'
    )

    # Ensure Profile exists (safe for tests with signals)
    await sync_to_async(Profile.objects.get_or_create)(user=user)

    # Log in and get token
    client = APIClient()
    login_response = await sync_to_async(client.post)(
        '/login/', {'email': 'testuser@test.com', 'password': 'testpass'}, format='json'
    )
    print("Login Response Status Code:", login_response.status_code)
    print("Login Response Data:", login_response.data)
    access_token = login_response.data['access']

    # WebSocket communicator with token
    communicator = WebsocketCommunicator(application, f"/ws/chat/testroom/?token={access_token}")
    communicator.scope['headers'] = [
        (b'authorization', f'Bearer {access_token}'.encode())
    ]
    communicator.scope['user'] = user  # simulate authenticated scope

    connected, _ = await communicator.connect()
    assert connected

    # Send message
    message_text = "Hello WebSocket!"
    await communicator.send_json_to({"message": message_text})

    # Receive message
    response = await communicator.receive_json_from()
    assert response['type'] == 'message'
    assert response['data']['message'] == message_text
    assert response['data']['sender'] == 'testuser'
    assert response['data']['room_name'] == 'testroom'

    await communicator.disconnect()
