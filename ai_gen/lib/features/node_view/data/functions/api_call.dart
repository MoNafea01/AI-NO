import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:dio/dio.dart';

class ApiCall {
  Future<Map<String, dynamic>> runNode(
    NodeModel node, {
    required Map<String, dynamic>? apiData,
  }) async {
    final dio = Dio();
    final Response response;

    try {
      if (node.nodeId == null) {
        response = await dio.post(
          "http://127.0.0.1:8000/api/${node.apiCall}",
          data: apiData,
          options: Options(contentType: Headers.jsonContentType),
        );
      } else {
        response = await dio.put(
          "http://127.0.0.1:8000/api/${node.apiCall}?node_id=${node.nodeId}",
          data: apiData,
          options: Options(contentType: Headers.jsonContentType),
        );
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.data);
        final Map<String, dynamic> mapResponse =
            Map<String, dynamic>.from(response.data);
        print(mapResponse);

        node.nodeId = mapResponse['node_id'];

        return mapResponse;
      } else {
        throw Exception('Failed to perform the operation');
      }
    } on DioException catch (e) {
      print("dio exception $e");
      return {"error": e.response?.data ?? "Server error"};
      if (e.response?.data != null) {
        throw Exception(
            'Failed to perform the operation with status code ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> getAPICall(
    String endpoint, {
    Map<String, dynamic>? apiData,
    Map<String, dynamic> Function(Map<String, dynamic>)? processResponse,
  }) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        "http://127.0.0.1:8000/api/$endpoint",
        data: apiData,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.data);
        final jsonResponse = Map<String, dynamic>.from(response.data);

        // Process response if a processor function is provided
        if (processResponse != null) {
          return processResponse(jsonResponse);
        }

        return jsonResponse;
      } else {
        throw Exception('Failed to perform the operation');
      }
    } on DioException catch (e) {
      print("dio exception $e");
      return {"error": e.response?.data ?? "Server error"};
      if (e.response?.data != null) {
        throw Exception(
            'Failed to perform the operation with status code ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> deleteNode(NodeModel node) async {
    final dio = Dio();
    try {
      print("deleeeeeting");
      final response = await dio.delete(
        "http://127.0.0.1:8000/api/${node.apiCall!}?node_id=${node.nodeId}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.data);
        final jsonResponse = Map<String, dynamic>.from(response.data);

        return jsonResponse;
      } else {
        throw Exception('Failed to perform the operation');
      }
    } on DioException catch (e) {
      print("dio exception $e");
      return {"error": e.response?.data ?? "Server error"};
      if (e.response?.data != null) {
        throw Exception(
            'Failed to perform the operation with status code ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
