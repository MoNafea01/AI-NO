# aino/chatbot/chat_history_utils.py
import os, sys
from cb.models import ChatBotHistory
from asgiref.sync import sync_to_async

@sync_to_async
def get_history(project_id: str):
    try:
        record = ChatBotHistory.objects.get(project_id=project_id)
        return record.history
    except ChatBotHistory.DoesNotExist:
        return []

@sync_to_async
def save_history(project_id: str, history: list):
    ChatBotHistory.objects.update_or_create(
        project_id=project_id,
        defaults={"history": history}
    )

@sync_to_async
def clear_history(project_id: str = None):
    if project_id:
        ChatBotHistory.objects.filter(project_id=project_id).delete()
    else:
        ChatBotHistory.objects.all().delete()
