import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final _storage = const FlutterSecureStorage();

// Future<http.Response> authorizedPost(
//   String url,
//   Map<String, dynamic> body,
// ) async {
//   final accessToken = await _storage.read(key: 'accessToken');
//   if (accessToken == null) {
//     throw Exception('Access token is missing.');
//   }

//   return await http.post(
//     Uri.parse(url),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $accessToken',
//     },
//     body: jsonEncode(body),
//   );
// }
Future<http.Response> authorizedPost(String url, body) async {
  final token = await _storage.read(key: 'accessToken');

  if (token == null) {
    throw Exception('No access token found');
  }

  return await http.post(
    Uri.parse(url),
    headers: {
      'Authorization':
          'Bearer $token', // Correct format with space after "Bearer"
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
}
