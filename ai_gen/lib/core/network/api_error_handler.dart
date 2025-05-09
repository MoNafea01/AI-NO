import 'package:dio/dio.dart';

class ApiErrorHandler {
  static Map<String, dynamic> dioHandler(DioException e) {
    if (e.response != null) {
      return {
        'Error': e.response!.data["message"] ??
            '${e.response?.statusMessage}, Status Code: ${e.response?.statusCode},${e.response?.data}'
      };
    } else {
      return {'Error': 'Unknown Internal Server Error'};
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
