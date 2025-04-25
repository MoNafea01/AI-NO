import 'dart:ui';

import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:ai_gen/features/node_view/data/serialization/node_serializer.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class NodeServerCalls {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsEndPoint = NetworkConstants.allComponentsEndPoint;
  final String _projectEndPoint = NetworkConstants.projectEndPoint;
  final String _nodesEndPoint = NetworkConstants.nodesEndPoint;

  final Dio _dio = GetIt.I.get<Dio>();

  Future<ProjectModel> createProject(
    String projectName,
    String projectDescription,
  ) async {
    print("Creating $_baseURL/$_projectEndPoint/");
    try {
      final Response response = await _dio.post(
        "$_baseURL/$_projectEndPoint/",
        data: {
          "project_name": projectName,
          "project_description": projectDescription,
        },
      );

      if (response.statusCode != null &&
          response.statusCode! < 300 &&
          response.statusCode! >= 200) {
        return ProjectModel.fromJson(response.data);
      } else {
        throw Exception("server error: error code ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      throw Exception("Server Error: $e");
    }
  }

  Future<ProjectModel> getProject(int projectId) async {
    try {
      final Response response = await _dio.get(
        "$_baseURL/$_projectEndPoint/$projectId/",
      );

      if (response.statusCode != null && response.statusCode! < 300 ||
          response.statusCode! >= 200) {
        return ProjectModel.fromJson(response.data);
      } else {
        throw Exception("server error: error code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Server Error: $e");
    }
  }

  Future<List<NodeModel>> getProjectNodes(int projectId) async {
    try {
      final Response response = await _dio.get(
        "$_baseURL/$_nodesEndPoint/?project_id=$projectId",
      );

      if (response.statusCode != null && response.statusCode! < 300 ||
          response.statusCode! >= 200) {
        List<NodeModel> nodes = [];

        if (response.data != null || response.data.isNotEmpty) {
          response.data.forEach(
            (nodeData) {
              if (nodeData["location_x"] == 0 && nodeData["location_y"] == 0) {
                // indicates fake node like the two outputs of the data loader
                return;
              }
              NodeModel? componentNode =
                  NodeSerializer.nodesDictionary[nodeData["uid"]];

              NodeModel? x = componentNode?.copyWith(
                projectId: nodeData["project"],
                nodeId: nodeData["node_id"],
                offset: Offset(nodeData["location_x"] ?? 350,
                    nodeData["location_y"] ?? 350),
                params: NodeSerializer.nodesDictionary[nodeData["uid"]]!.params
                    .map((componentParameter) {
                  print(nodeData["params"]?.firstWhere(
                    (param) => param[componentParameter.name] != null,
                  )[componentParameter.name]);
                  if (nodeData["params"] is List &&
                      nodeData["params"].isNotEmpty) {
                    return componentParameter.copyWith(
                      value: nodeData["params"]?.firstWhere(
                        (param) => param[componentParameter.name] != null,
                      )[componentParameter.name],
                    );
                  }
                  return componentParameter.copyWith();
                }).toList(),
              );
              if (x != null) nodes.add(x);
            },
          );

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

  Future updateProjectNodes(List<Map> nodes, int projectId) async {
    try {
      print("project Nodes: $nodes");
      final Response response = await _dio.put(
        "$_baseURL/$_nodesEndPoint/?project_id=$projectId",
        data: nodes,
      );

      if (response.statusCode != null && response.statusCode! < 300 ||
          response.statusCode! >= 200) {
        return response.data;
      } else {
        throw Exception("server error: error code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Server Error: $e");
    }
  }

  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final Response response = await _dio.get(
        "$_baseURL/$_projectEndPoint/",
      );

      if (response.statusCode != null && response.statusCode! < 300 ||
          response.statusCode! >= 200) {
        List<ProjectModel> projects = [];
        if (response.data != null || response.data.isNotEmpty) {
          response.data.forEach((projectData) {
            ProjectModel project = ProjectModel.fromJson(projectData);
            projects.add(project);
          });

          return projects;
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

  Future<Map<int, NodeModel>> loadNodesComponents() async {
    try {
      final Response response =
          await _dio.get("$_baseURL/$_allComponentsEndPoint");

      Map<int, NodeModel> nodesDictionary = {};

      if (response.statusCode != null && response.statusCode! < 300 ||
          response.statusCode! >= 200) {
        if (response.data != null) {
          response.data.forEach(
            (nodeData) {
              NodeModel node = NodeModel.fromJson(nodeData);
              if (nodeData['uid'] != null) {
                nodesDictionary[nodeData['uid']] = node;
              } else {
                print("Node:${node.name} returned with uid is null");
              }
            },
          );

          return nodesDictionary;
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
    print("Node ${node.displayName} :$apiBody");
    node.paramsToJson.forEach(
      (key, value) {
        print("$key : $value(${value.runtimeType})");
      },
    );

    return await _apiCall(
      node: node,
      apiCall: (dio) async {
        if (node.nodeId == null) {
          return _postNode(_dio, node, apiBody);
        } else {
          return _putNode(_dio, node, apiBody);
        }
      },
      onResponseSuccess: (Map<String, dynamic> mapResponse) {
        node.nodeId = mapResponse['node_id'];
      },
    );
  }

  Future<Response> _postNode(Dio dio, NodeModel node, dynamic apiBody) async {
    return await dio.post(
      "$_baseURL/${node.endPoint}?project_id=${node.projectId}",
      data: apiBody,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> _putNode(Dio dio, NodeModel node, dynamic apiBody) async {
    final x = await dio.put(
      "$_baseURL/${node.endPoint}?node_id=${node.nodeId}&project_id=${node.projectId}",
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
          "$_baseURL/${node.endPoint!}?node_id=${node.nodeId}&output=$outputChannel&project_id=${node.projectId}",
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
          "$_baseURL/${node.endPoint!}?node_id=${node.nodeId}&project_id=${node.projectId}",
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
