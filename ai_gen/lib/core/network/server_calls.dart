import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:dio/dio.dart';

import 'network_constants.dart';

class ServerCalls {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsApi = NetworkConstants.allComponentsApi;

  final Dio dio = Dio();

  Future<List<NodeModel>> getNodes() async {
    try {
      final Response response = await dio.get("$_baseURL/$_allComponentsApi");
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
}
