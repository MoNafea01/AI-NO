import 'dart:async';

import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService;
  final int projectId;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  GridNodeViewCubit gridNodeViewCubit;

  ChatController(this._chatService,
      {required this.projectId, required this.gridNodeViewCubit}) {
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
    Timer? updateNodesTimer;

    late final dynamic response;
    try {
      updateNodesTimer = Timer.periodic(
        const Duration(seconds: 5),
        (timer) => gridNodeViewCubit.updateNodes(),
      );

      try {
        response = await _chatService.sendMessage(
          projectId: projectId,
          userInput: userInput,
        );
      } finally {
        updateNodesTimer.cancel();
        gridNodeViewCubit.updateNodes();
        updateNodesTimer = null;
      }

      final output = response['output'] ?? '';
      if (output.isNotEmpty) {
        _messages.add(ChatMessage(sender: 'bot', text: output.toString()));
      }
    } catch (e) {
      _messages.add(ChatMessage(sender: 'bot', text: 'Error: ${e.toString()}'));
    }
    _isLoading = false;
    notifyListeners();
  }
}
