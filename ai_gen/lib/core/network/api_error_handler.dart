import 'package:dio/dio.dart';

class ApiErrorHandler {
  static Exception dioHandler(DioException e) {
    // Handle response errors (non-2xx HTTP status codes)
    if (e.type == DioExceptionType.badResponse && e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String message = 'Unexpected server response.';

      if (responseData != null) {
        if (responseData is Map) {
          // Check common fields for backend error messages
          if (responseData.containsKey('message') &&
              responseData['message'] is String) {
            message = responseData['message'];
            return Exception(message);
          }
          if (responseData.containsKey('error') &&
              responseData['error'] is String) {
            message = responseData['error'];
            return Exception(message);
          }
        } else if (responseData is String) {
          // Sometimes backend returns plain text error message
          message = responseData;
          return Exception(message);
        }
      }

      // fallback to status message
      if (e.response?.statusMessage != null) {
        message = '${e.response?.statusMessage} (Status Code: $statusCode)';
      }

      return Exception('Server Error: $message');
    }

    // Handle timeouts
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please try again later.');
    }

    // Handle no internet / network errors
    if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Check your network.');
    }

    // Cancelled requests
    if (e.type == DioExceptionType.cancel) {
      return Exception('Request was cancelled.');
    }

    // Fallback for anything else
    return Exception('Unexpected error: ${e.message ?? 'Unknown error'}');
  }

  static Exception handleGeneral(Exception e) {
    return Exception('Unexpected internal error: ${e.hashCode}');
  }

  static String extractMessage(error) {
    if (error is DioException) {
      return dioHandler(error).toString().replaceFirst('Exception: ', '');
    } else if (error is Exception) {
      return handleGeneral(error).toString().replaceFirst('Exception: ', '');
    } else {
      return "Unknown error occurred";
    }
  }
}
