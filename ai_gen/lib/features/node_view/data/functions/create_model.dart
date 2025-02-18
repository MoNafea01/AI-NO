import 'package:ai_gen/core/classes/model_class.dart';
import 'package:dio/dio.dart';

Future<AIModel> apiCall(Map<String, dynamic> modelData) async {
  final dio = Dio();

  Map<String, dynamic> data = {
    "model_name": modelData['model_name'],
    "model_type": modelData['model_type'],
    "task": modelData['task'],
    "params": modelData['params'],
  };

  // print(data);
  try {
    final response = await dio.post(
      'http://127.0.0.1:8000/api/create_model/',
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = response.data;
      final model = AIModel.fromJson(jsonResponse);
      return model;
    } else {
      throw Exception('Failed to perform createModel');
    }
  } on DioException catch (e) {
    // Handle Dio-specific exceptions
    if (e.response != null) {
      print(e.response?.data);
      throw Exception(
          'Failed to perform createModel: ${e.response?.statusCode}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}
