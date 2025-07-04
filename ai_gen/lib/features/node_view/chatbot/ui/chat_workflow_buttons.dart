import 'package:ai_gen/features/node_view/chatbot/controller/chat_controller.dart';
import 'package:flutter/material.dart';

class ChatWorkflowButtons extends StatelessWidget {
  const ChatWorkflowButtons({
    required this.chatController,
    this.recommendedMessages = const [],
    super.key,
  });
  final ChatController chatController;
  final List<String> recommendedMessages;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          recommendedMessages.length,
          (index) => ElevatedButton(
            onPressed: () {
              chatController.sendMessage(recommendedMessages[index]);
            },
            child: Text(recommendedMessages[index]),
          ),
        ),
      ),
    );
  }
}
