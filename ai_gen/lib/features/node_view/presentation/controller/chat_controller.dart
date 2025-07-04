import 'package:flutter/material.dart';

import '../../data/services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService;
  final int projectId;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatController(this._chatService, {required this.projectId}) {
    loadChatHistory();
  }

  Future<void> loadInitialMessages(List<dynamic>? chatHistory) async {
    if (chatHistory != null) {
      _messages = _chatService.parseChatHistory(chatHistory);
      notifyListeners();
    }
  }

  Future<void> loadChatHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _messages = await _chatService.fetchChatHistory(projectId: projectId);
    } catch (e) {
      _messages = [
        ChatMessage(sender: 'bot', text: 'Failed to load chat history.')
      ];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String userInput) async {
    _isLoading = true;
    _messages.add(ChatMessage(sender: 'user', text: userInput));
    notifyListeners();
    try {
      final response = await _chatService.sendMessage(
        projectId: projectId,
        userInput: userInput,
      );
      final output = response['output'] ?? '';
      if (output.isNotEmpty) {
        _messages.add(ChatMessage(sender: 'bot', text: output));
      }
      // Optionally update full chat history from response
      // final chatHistory = response['chat_history'] as List<dynamic>?;
      // if (chatHistory != null) {
      //   _messages = _chatService.parseChatHistory(chatHistory);
      // }
    } catch (e) {
      _messages.add(ChatMessage(sender: 'bot', text: 'Error: ${e.toString()}'));
    }
    _isLoading = false;
    notifyListeners();
  }
}
