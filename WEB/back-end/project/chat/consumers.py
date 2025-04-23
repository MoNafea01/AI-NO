import json
import jwt
import datetime
from channels.generic.websocket import AsyncWebsocketConsumer
from django.conf import settings
from asgiref.sync import sync_to_async
from accounts.models import User
from .models import Room, Message

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope.get('user')
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'chat_{self.room_name}'

        
        self.user = await sync_to_async(User.objects.get)(id=self.user.id)
        
        self.room = await sync_to_async(Room.objects.get_or_create)(room_name=self.room_name)
        try:    
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )
            await self.accept()
        except Exception as e:
            print(f"Connection error: {e}")
            await self.close(code=4000)

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            message_content = data['message']
            # message_content = data.get('message' , '')
            
            await self.save_message(message_content)
            
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': message_content,
                    'sender': self.user.username,
                    'sender_id': str(self.user.id),
                    'timestamp': datetime.datetime.now().isoformat(),
                    'room_name': self.room_name
                }
            )
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'error': 'Invalid JSON format'
            }))
        except Exception as e:
            print(f"Message processing error: {e}")

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'type': 'message',
            'data': {
                'message': event['message'],
                'sender': event['sender'],
                'sender_id': event['sender_id'],
                'timestamp': event['timestamp'],
                'room_name': event['room_name']
            }
        }))

    @sync_to_async
    def save_message(self, content):
        Message.objects.create(
            room_name=self.room[0],
            sender=self.user,
            content=content
        )