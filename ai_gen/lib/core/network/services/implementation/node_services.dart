import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/network/api_error_handler.dart';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:ai_gen/core/network/services/interfaces/node_services_interface.dart';
import 'package:dio/dio.dart';

class NodeServices implements INodeServices {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsEndPoint = NetworkConstants.allComponentsEndPoint;
  final String _nodesEndPoint = NetworkConstants.nodesEndPoint;

  final Dio _dio;

  NodeServices(this._dio);

  @override
  Future<Map<int, NodeModel>> loadNodesComponents() async {
    try {
      final response = await _dio.get("$_baseURL/$_allComponentsEndPoint");

      Map<int, NodeModel> nodesDictionary = {};
      if (response.data != null) {
        for (var nodeData in response.data) {
          NodeModel node = NodeModel.fromJson(nodeData);
          if (nodeData['uid'] != null && nodeData['uid'] is int) {
            nodesDictionary[nodeData['uid']] = node;
          }
        }
      }
      return nodesDictionary;
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      if (e is Exception) {
        throw ApiErrorHandler.handleGeneral(e);
      } else {
        throw Exception('Unknown error: $e');
      }
    }
  }

  @override
  Future<Response> loadProjectNodes(int projectId) async {
    try {
      final response =
          await _dio.get("$_baseURL/$_nodesEndPoint/?project_id=$projectId");

      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      if (e is Exception) {
        throw ApiErrorHandler.handleGeneral(e);
      } else {
        throw Exception('Unknown error: $e');
      }
    }
  }

  @override
  Future<void> saveProjectNodes(List<Map> nodes, int projectId) async {
    try {
      await _dio.put(
        "$_baseURL/$_nodesEndPoint/?project_id=$projectId",
        data: nodes,
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      if (e is Exception) {
        throw ApiErrorHandler.handleGeneral(e);
      } else {
        throw Exception('Unknown error: $e');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> runNode(NodeModel node, apiBody) async {
    print(
        "Running node: ${node.name}: $_baseURL/${node.endPoint}?node_id=${node.nodeId}&project_id=${node.projectId}  \nwith body $apiBody");
    return await _apiCall(
      node,
      () async => node.nodeId == null
          ? _postNode(node, apiBody)
          : _putNode(node, apiBody),
      onResponseSuccess: (mapResponse) {
        node.nodeId = mapResponse['node_id'];
      },
    );
  }

  Future<Response> _postNode(NodeModel node, apiBody) {
    return _dio.post(
      "$_baseURL/${node.endPoint}?project_id=${node.projectId}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> _putNode(NodeModel node, apiBody) {
    return _dio.put(
      "$_baseURL/${node.endPoint}?node_id=${node.nodeId}&project_id=${node.projectId}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  @override
  Future<Map<String, dynamic>> getNode(
    NodeModel node,
    int outputChannel,
  ) async {
    return _apiCall(
      node,
      () => _dio.get(
        "$_baseURL/${node.endPoint}?node_id=${node.nodeId}&output=$outputChannel&project_id=${node.projectId}",
        options: Options(contentType: Headers.jsonContentType),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> deleteNode(NodeModel node) async {
    await _apiCall(
      node,
      () => _dio.delete(
        "$_baseURL/${node.endPoint}?node_id=${node.nodeId}&project_id=${node.projectId}",
      ),
    );
    return {"message": "${node.name} deleted successfully"};
  }

  Future<Map<String, dynamic>> _apiCall(
    NodeModel node,
    Future<Response> Function() apiCall, {
    Function(Map<String, dynamic> mapResponse)? onResponseSuccess,
  }) async {
    try {
      final response = await apiCall();

      Map<String, dynamic> mapResponse = response.data != null
          ? Map<String, dynamic>.from(response.data)
          : {"error": "Server returned empty response"};

      if (onResponseSuccess != null) onResponseSuccess(mapResponse);
      return mapResponse;
    } on DioException catch (e) {
      return {"error": ApiErrorHandler.extractMessage(e)};
    } catch (e) {
      if (e is Exception) {
        throw ApiErrorHandler.handleGeneral(e);
      } else {
        throw Exception('Unknown error: $e');
      }
    }
  }
}
