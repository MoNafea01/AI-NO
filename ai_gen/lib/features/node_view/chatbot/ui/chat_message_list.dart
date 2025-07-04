import 'package:ai_gen/features/node_view/chatbot/services/chat_service.dart';
import 'package:flutter/material.dart';

import 'chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  const ChatMessageList({required this.messages, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.sender == 'user';
        return ChatMessageBubble(text: msg.text, isUser: isUser);
      },
    );
  }
}
