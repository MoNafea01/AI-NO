// features/auth/data/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final baseUrl = 'http://your-api-url.com';

  Future<Map<String, dynamic>> login(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return jsonDecode(response.body);
  }
}
