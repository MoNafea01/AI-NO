import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class NodeServerCalls {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsEndPoint = NetworkConstants.allComponentsApi;

  final Dio _dio = GetIt.I.get<Dio>();

  Future<List<NodeModel>> loadAllNodes() async {
    try {
      final Response response =
          await _dio.get("$_baseURL/$_allComponentsEndPoint");
      List<NodeModel> nodes = [];

      if (response.statusCode == 200) {
        if (response.data != null) {
          response.data.forEach((nodeData) {
            NodeModel node = NodeModel.fromJson(nodeData);
            nodes.add(node);
          });

          return nodes;
        } else {
          throw Exception('server error: response data is null');
        }
      } else {
        throw Exception("server error: error code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Server Error: $e");
    }
  }

  Future<Map<String, dynamic>> runNode(NodeModel node, dynamic apiBody) async {
    return await _apiCall(
      node: node,
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
      "$_baseURL/${node.endPoint}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> _put(Dio dio, NodeModel node, dynamic apiBody) async {
    final x = await dio.put(
      "$_baseURL/${node.endPoint}?node_id=${node.nodeId}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );

    return x;
  }

  Future<Map<String, dynamic>> getNode(
    NodeModel node,
    int outputChannel, {
    Map<String, dynamic>? apiBody,
  }) async {
    return _apiCall(
      node: node,
      apiCall: (dio) async {
        return await dio.get(
          "$_baseURL/${node.endPoint!}?node_id=${node.nodeId}&output=$outputChannel",
          data: apiBody,
          options: Options(contentType: Headers.jsonContentType),
        );
      },
    );
  }

  Future<Map<String, dynamic>> deleteNode(NodeModel node) async {
    _apiCall(
      node: node,
      apiCall: (dio) async {
        return await dio.delete(
          "$_baseURL/${node.endPoint!}?node_id=${node.nodeId}",
        );
      },
    );
    return {"message": "${node.name} deleted Successfully"};
  }

  Future<Map<String, dynamic>> _apiCall({
    required NodeModel node,
    required Future<Response?> Function(Dio dio) apiCall,
    Function(Map<String, dynamic> mapResponse)? onResponseSuccess,
  }) async {
    final Dio dio = GetIt.I.get<Dio>();

    try {
      final Response? response = await apiCall(dio);
      late final Map<String, dynamic> mapResponse;

      if (response?.statusCode != null &&
          response!.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data == null) {
          mapResponse = {node.name: "Server error: response data is null"};
        } else {
          mapResponse = Map<String, dynamic>.from(response.data);
        }

        print(mapResponse);
        if (onResponseSuccess != null) onResponseSuccess(mapResponse);
        return mapResponse;
      } else {
        return {node.name: "Server error: ${response?.statusCode}"};
      }
    } on DioException catch (e) {
      print("Dio Exception ELDemy: $e");

      if (e.response != null) {
        return {
          "error": e.response?.statusMessage,
          "status code": e.response?.statusCode,
        };
      } else {
        return {"error": "Unknown Internal Server Error"};
      }
    } on Exception catch (e) {
      print("Exception: $e");
      return {"error": "Unknown Internal Server Error"};
    }
  }
}
