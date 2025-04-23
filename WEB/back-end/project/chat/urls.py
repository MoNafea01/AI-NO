from django.urls import path
from .views import RoomMessagesAPIView , RoomAPIView
from django.views.generic import TemplateView
urlpatterns = [
    path('rooms/', RoomAPIView.as_view(), name='rooms'),
    path('messages/<str:room_name>/', RoomMessagesAPIView.as_view(), name='room-messages'),
]