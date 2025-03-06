import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:dio/dio.dart';

class ApiCall {
  Future<Map<String, dynamic>> runNode(NodeModel node, dynamic apiBody) async {
    return await _apiCall(
      apiCall: (dio) async {
        if (node.nodeId == null) {
          return _post(dio, node, apiBody);
        } else {
          return _put(dio, node, apiBody);
        }
      },
      onResponseSuccess: (Map<String, dynamic> mapResponse) {
        node.nodeId = mapResponse['node_id'];
      },
    );
  }

  Future<Response> _post(Dio dio, NodeModel node, dynamic apiBody) async {
    return await dio.post(
      "http://127.0.0.1:8000/api/${node.apiCall}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> _put(Dio dio, NodeModel node, dynamic apiBody) async {
    return await dio.put(
      "http://127.0.0.1:8000/api/${node.apiCall}?node_id=${node.nodeId}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Map<String, dynamic>> getNode(
    NodeModel node,
    int outputChannel, {
    Map<String, dynamic>? apiBody,
  }) async {
    return _apiCall(
      apiCall: (dio) async {
        return await dio.get(
          "http://127.0.0.1:8000/api/${node.apiCall!}?node_id=${node.nodeId}&output=$outputChannel",
          data: apiBody,
          options: Options(contentType: Headers.jsonContentType),
        );
      },
    );
  }

  Future<Map<String, dynamic>> deleteNode(NodeModel node) async {
    return _apiCall(
      apiCall: (dio) async {
        return await dio.delete(
          "http://127.0.0.1:8000/api/${node.apiCall!}?node_id=${node.nodeId}",
        );
      },
    );
  }

  Future<Map<String, dynamic>> _apiCall({
    required Future<Response> Function(Dio dio) apiCall,
    Function(Map<String, dynamic> mapResponse)? onResponseSuccess,
  }) async {
    final dio = Dio();
    final Response response;

    try {
      response = await apiCall(dio);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> mapResponse =
            Map<String, dynamic>.from(response.data);
        print(mapResponse);

        if (onResponseSuccess != null) onResponseSuccess(mapResponse);

        return mapResponse;
      } else {
        throw Exception('Failed to perform the operation');
      }
    } on DioException catch (e) {
      print("dio exception $e");
      if (e.response?.data != null) {
        return {"error": e.response?.data ?? "Server error"};
        throw Exception(
            'Failed to perform the operation with status code ${e.response?.statusCode}');
      } else {
        return {"error": "Server error"};
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
