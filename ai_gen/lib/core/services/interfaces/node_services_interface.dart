import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:dio/dio.dart';

abstract class INodeServices {
  Future<Map<int, NodeModel>> loadNodesComponents();
  Future<Map<String, dynamic>> runNode(NodeModel node, apiBody);
  Future<Map<String, dynamic>> getNode(NodeModel node, int outputChannel,
      {Map<String, dynamic>? apiBody});
  Future<Map<String, dynamic>> deleteNode(NodeModel node);
  Future<Response> loadProjectNodes(int projectId);
  Future<void> saveProjectNodes(List<Map> nodes, int projectId);
}
