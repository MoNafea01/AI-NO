import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? code;
  final String? type;

  ApiException(this.message, {this.code, this.type});

  @override
  String toString() => 'ApiException: $message';
}

class ApiErrorHandler {
  static ApiException dioHandler(DioException e) {
    if (e.type == DioExceptionType.badResponse && e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String message = '';
      String errorType = 'ServerError';

      // Try to extract message from response
      if (responseData != null) {
        if (responseData is Map) {
          if (responseData.containsKey('message') &&
              responseData['message'] is String) {
            message = responseData['message'];
          } else if (responseData.containsKey('error') &&
              responseData['error'] is String) {
            message = responseData['error'];
          }
        }
      }

      // Handle specific status codes
      switch (statusCode) {
        case 400:
          errorType = 'BadRequest';
          message = message.isNotEmpty ? message : 'Bad request.';
          break;
        case 401:
          errorType = 'Unauthorized';
          message = message.isNotEmpty
              ? message
              : 'Unauthorized. Please log in again.';
          break;
        case 403:
          errorType = 'Forbidden';
          message = message.isNotEmpty
              ? message
              : 'You do not have permission to perform this action.';
          break;
        case 404:
          errorType = 'NotFound';
          message = message.isNotEmpty
              ? message
              : 'Not Found. Please Update the app.';
          break;
        case 409:
          errorType = 'Conflict';
          message = message.isNotEmpty ? message : 'Conflict occurred.';
          break;
        case 422:
          errorType = 'UnprocessableEntity';
          message = message.isNotEmpty ? message : 'Unprocessable entity.';
          break;
        case 500:
          errorType = 'InternalServerError';
          message = message.isNotEmpty ? message : 'Internal server error.';
          break;
        default:
          errorType = 'HttpError';
          message = message.isNotEmpty
              ? message
              : (e.response?.statusMessage != null
                  ? '${e.response?.statusMessage} (Status Code: $statusCode)'
                  : 'HTTP error with status code $statusCode');
      }

      return ApiException(message, code: statusCode, type: errorType);
    }

    // Handle timeouts
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Connection timeout. Please try again later.',
          type: 'Timeout');
    }

    // Handle no internet / network errors
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('No internet connection. Check your network.',
          type: 'Network');
    }

    // Cancelled requests
    if (e.type == DioExceptionType.cancel) {
      return ApiException('Request was cancelled.', type: 'Cancelled');
    }

    // Fallback for anything else
    return ApiException('Unexpected error: ${e.message ?? 'Unknown error'}',
        type: 'Unknown');
  }

  static ApiException handleGeneral(Exception e) {
    return ApiException('Unexpected internal error occurred.',
        type: 'Internal');
  }

  static String extractMessage(error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is DioException) {
      return dioHandler(error).message;
    } else if (error is Exception) {
      return handleGeneral(error).message;
    } else {
      return "Unknown error occurred";
    }
  }
}
