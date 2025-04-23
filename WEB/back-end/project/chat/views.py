from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Message , Room
from .serializers import MessageSerializer , RoomSerializer

class RoomMessagesAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, room_name):
        # Fetch messages filtered by room_name
        room = Room.objects.filter(room_name=room_name).first()  # Ensure room exists
        if room:
            messages = Message.objects.filter(room_name=room).order_by('timestamp')
            return Response(MessageSerializer(messages, many=True).data)
        else:
            return Response({'error': 'Room not found'}, status=404)


class RoomAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        room = Room.objects.all()
        return Response(RoomSerializer(room, many=True).data)
