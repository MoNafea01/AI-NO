import 'package:ai_gen/core/network/network_constants.dart';
import 'package:dio/dio.dart';

class ChatMessage {
  final String sender; // 'user' or 'bot'
  final String text;
  ChatMessage({required this.sender, required this.text});
}

class ChatService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> sendMessage({
    required int projectId,
    required String userInput,
    String model = 'gemini-2.0-flash',
    bool toDb = true,
  }) async {
    final url = '${NetworkConstants.chatBaseURL}/chatbot?project_id=$projectId';
    final body = {
      'user_input': userInput,
      // 'to_db': toDb,
      // 'model': model,
    };
    final response = await _dio.post(url, data: body);
    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data;
    } else {
      throw Exception('Failed to get chat response');
    }
  }

  List<ChatMessage> parseChatHistory(List<dynamic> chatHistory) {
    final List<ChatMessage> messages = [];
    for (final entry in chatHistory) {
      if (entry['user'] != null && entry['user'].toString().isNotEmpty) {
        messages.add(ChatMessage(sender: 'user', text: entry['user']));
      }
      if (entry['bot'] != null && entry['bot'].toString().isNotEmpty) {
        messages.add(ChatMessage(sender: 'bot', text: entry['bot']));
      }
    }

    return messages;
  }

  Future<List<ChatMessage>> fetchChatHistory({required int projectId}) async {
    final url =
        '${NetworkConstants.chatBaseURL}/chat-history?project_id=$projectId';
    final response = await _dio.get(url);

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final chatHistory = response.data['chat_history'] as List<dynamic>?;
      if (chatHistory != null) {
        return parseChatHistory(chatHistory);
      }
      return [];
    } else {
      throw Exception('Failed to fetch chat history');
    }
  }
}
