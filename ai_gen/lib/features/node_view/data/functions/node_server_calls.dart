import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class NodeServerCalls {
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
    print("ELDemy:: ${node.nodeId}: ${DateTime.timestamp()}");

    final x = await dio.put(
      "http://127.0.0.1:8000/api/${node.apiCall}?node_id=${node.nodeId}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
    print("ELDemy:: ${x}");

    return x;
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
    _apiCall(
      apiCall: (dio) async {
        return await dio.delete(
          "http://127.0.0.1:8000/api/${node.apiCall!}?node_id=${node.nodeId}",
        );
      },
    );
    return {"message": "${node.name} deleted Successfully"};
  }

  Future<Map<String, dynamic>> _apiCall({
    required Future<Response?> Function(Dio dio) apiCall,
    Function(Map<String, dynamic> mapResponse)? onResponseSuccess,
  }) async {
    final Dio dio = GetIt.I.get<Dio>();

    try {
      final Response? response = await apiCall(dio);
      print("Response Status Code: ${response?.statusCode}");

      if (response?.statusCode != null &&
          response!.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final Map<String, dynamic> mapResponse =
            Map<String, dynamic>.from(response.data);
        print(mapResponse);

        if (onResponseSuccess != null) onResponseSuccess(mapResponse);

        return mapResponse;
      } else {
        throw Exception('Failed to perform the operation');
      }
    } on DioException catch (e) {
      print("Dio Exception: $e");

      if (e.response?.data != null) {
        return {"error": e.response?.data ?? "Server error"};
      } else {
        return {"error": "Network error: ${e.message}"};
      }
    }
  }
}
// Future<Map<String, dynamic>> oldRunNode(
//   NodeModel node, {
//   required Map<String, dynamic>? apiData,
// }) async {
//   final dio = Dio();
//   final Response response;
//
//   try {
//     if (node.nodeId == null) {
//       response = await dio.post(
//         "http://127.0.0.1:8000/api/${node.apiCall}",
//         data: apiData,
//         options: Options(contentType: Headers.jsonContentType),
//       );
//     } else {
//       response = await _put(dio, node, apiData);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final Map<String, dynamic> mapResponse =
//           Map<String, dynamic>.from(response.data);
//       print(mapResponse);
//
//       node.nodeId = mapResponse['node_id'];
//
//       return mapResponse;
//     } else {
//       throw Exception('Failed to perform the operation');
//     }
//   } on DioException catch (e) {
//     print("dio exception $e");
//     return {"error": e.response?.data ?? "Server error"};
//     if (e.response?.data != null) {
//       throw Exception(
//           'Failed to perform the operation with status code ${e.response?.statusCode}');
//     } else {
//       throw Exception('Network error: ${e.message}');
//     }
//   }
// }
//
// Future<Map<String, dynamic>> getAPICall(
//   String endpoint, {
//   Map<String, dynamic>? apiData,
//   Map<String, dynamic> Function(Map<String, dynamic>)? processResponse,
// }) async {
//   final dio = Dio();
//
//   try {
//     final Response response = await getNode(dio, endpoint, apiData);
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print(response.data);
//       final jsonResponse = Map<String, dynamic>.from(response.data);
//
//       // Process response if a processor function is provided
//       if (processResponse != null) {
//         return processResponse(jsonResponse);
//       }
//
//       return jsonResponse;
//     } else {
//       throw Exception('Failed to perform the operation');
//     }
//   } on DioException catch (e) {
//     print("dio exception $e");
//     return {"error": e.response?.data ?? "Server error"};
//     if (e.response?.data != null) {
//       throw Exception(
//           'Failed to perform the operation with status code ${e.response?.statusCode}');
//     } else {
//       throw Exception('Network error: ${e.message}');
//     }
//   }
// }
//
// Future<Map<String, dynamic>> deleteNode(NodeModel node) async {
//   final dio = Dio();
//   try {
//     final Response response = await delete(dio, node);
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print(response.data);
//       final jsonResponse = Map<String, dynamic>.from(response.data);
//
//       return jsonResponse;
//     } else {
//       throw Exception('Failed to perform the operation');
//     }
//   } on DioException catch (e) {
//     print("dio exception $e");
//     return {"error": e.response?.data ?? "Server error"};
//     if (e.response?.data != null) {
//       throw Exception(
//           'Failed to perform the operation with status code ${e.response?.statusCode}');
//     } else {
//       throw Exception('Network error: ${e.message}');
//     }
//   }
// }
