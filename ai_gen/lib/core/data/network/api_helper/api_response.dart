import 'package:dio/dio.dart';

class ApiResponse {
  final bool status;
  final int statusCode;
  final dynamic data;
  final String message;

  ApiResponse({
    required this.status,
    required this.statusCode,
    required this.message, this.data,
  });

  // Factory method to handle Dio responses
  factory ApiResponse.fromResponse(Response response) {
    return ApiResponse(
      status: response.data["status"] ?? false,
      statusCode: response.statusCode ?? 500,
      data: response.data,
      message: response.data["message"] ?? 'An error occurred.',
    );
  }

  // Factory method to handle Dio or other exceptions
  factory ApiResponse.fromError(dynamic error) {
    // ignore: avoid_print
    print(error.toString());
    if (error is DioException) {
      // ignore: avoid_print
      return ApiResponse(
        status: false,
        data: error.response?.data,
        statusCode:
            error.response != null ? error.response!.statusCode ?? 500 : 500,
        message: _handleDioError(error),
      );
    } else {
      return ApiResponse(
        status: false,
        statusCode: 500,
        message: 'An error occurred.',
      );
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout, please try again.";
      case DioExceptionType.sendTimeout:
        return "Send timeout, please check your internet.";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout, please try again later.";
      case DioExceptionType.badResponse:
        return _handleServerError(error.response);
      case DioExceptionType.cancel:
        return "Request was cancelled.";
      case DioExceptionType.connectionError:
        return "No internet connection.";
      default:
        return "Unknown error occurred.";
    }
  }

  /// Handling errors from the server response
  static String _handleServerError(Response? response) {
    if (response == null) return "No response from server.";
    if (response.data is Map<String, dynamic>) {
      if (response.data["message"] != null) {
        print("----- Handle Server Error ${response.data["message"]}");
        return response.data["message"];
      }
      return "An error occurred.";
    }
    return "Server error: ${response.statusMessage}";
  }
}
