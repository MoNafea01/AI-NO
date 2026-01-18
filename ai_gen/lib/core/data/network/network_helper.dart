import 'dart:convert';
import 'dart:developer';
import 'package:ai_gen/core/data/cache/cache_helper.dart';
import 'package:ai_gen/core/data/cache/cahch_keys.dart';
import 'package:http/http.dart' as http;



Future<http.Response> authorizedPost(String url, body) async {
  final token =await CacheHelper.getData(
    key: CacheKeys.accessToken,
  
  );
 
 // final token = await _storage.read(key: 'accessToken');
  log('Access Token: $token'); // Debugging line to check token

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
