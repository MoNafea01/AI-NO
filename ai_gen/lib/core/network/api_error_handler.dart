import 'package:dio/dio.dart';

class ApiErrorHandler {
  static Map<String, dynamic> dioHandler(DioException e) {
    if (e.response != null) {
      final message =
          e.response!.data is Map ? e.response!.data["message"] : null;

      return {
        'Error': message ??
            '${e.response?.statusMessage}, Status Code: ${e.response?.statusCode}'
      };
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return {
        'Error': 'Connection timeout. Please check your internet connection.'
      };
    } else if (e.type == DioExceptionType.connectionError) {
      return {
        'Error': 'No internet connection. Please check your network settings.'
      };
    } else {
      return {'Error': e.message ?? 'Unknown Internal Server Error'};
    }
  }

  static Exception handleGeneral(Exception e) {
    return Exception('Unknown Internal Server Error: ${e.toString()}');
  }

  static void checkResponseStatus(Response response) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Server error: Status code ${response.statusCode}');
    }
  }
}
