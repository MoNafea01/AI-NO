from channels.testing import WebsocketCommunicator
from django.test import TestCase
from channels.layers import get_channel_layer
from django.contrib.auth import get_user_model
from chat.consumers import ChatConsumer
from chat.models import Room, Message
import json
import asyncio

class WebSocketTests(TestCase):
    def setUp(self):
        # إعداد المستخدم للاختبار
        self.user = get_user_model().objects.create_user(
            username='ahmed', email='	anaahmed1512@gmail.com', password='Ah12101990'
        )
        # إنشاء غرفة لاختبار الاتصال بها
        self.room_name = 'testroom'
        self.room = Room.objects.create(room_name=self.room_name)

    async def test_websocket_connection(self):
        # إعداد الاتصال بـ WebSocket
        communicator = WebsocketCommunicator(
            ChatConsumer.as_asgi(),
            f"/ws/chat/{self.room_name}/"
        )

        # تأكيد أن الاتصال تم بنجاح
        connected, subprotocol = await communicator.connect()
        self.assertTrue(connected)

        # إرسال رسالة عبر WebSocket
        message = {'message': 'Hello, world!'}
        await communicator.send_json_to(message)

        # التحقق من أن الرسالة قد وصلت إلى المتصلين
        response = await asyncio.wait_for(communicator.receive_json_from(), timeout=5)  # زيادة مدة الانتظار
        self.assertEqual(response['message'], 'Hello, world!')

        # قطع الاتصال
        await communicator.disconnect()

    async def test_websocket_message_saving(self):
        # إعداد الاتصال بـ WebSocket
        communicator = WebsocketCommunicator(
            ChatConsumer.as_asgi(),
            f"/ws/chat/{self.room_name}/"
        )
        connected, subprotocol = await communicator.connect()
        self.assertTrue(connected)

        # إرسال رسالة عبر WebSocket
        message = {'message': 'Test message'}
        await communicator.send_json_to(message)

        # التحقق من أن الرسالة تم حفظها في قاعدة البيانات
        await communicator.receive_json_from()  # انتظر الرد

        # تحقق من وجود الرسالة في قاعدة البيانات
        msg = Message.objects.filter(content='Test message').first()
        self.assertIsNotNone(msg)

        # قطع الاتصال
        await communicator.disconnect()
