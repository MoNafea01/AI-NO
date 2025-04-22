import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:get_it/get_it.dart';

import '../api_services/node_server_calls.dart';

class NodeSerializer {
  Future<Map<String, Map<String, Map<String, List<NodeModel>>>>>
      categorizeNodes() async {
    try {
      NodeServerCalls serverCalls = GetIt.I.get<NodeServerCalls>();
      // read the nodes from the server
      List<NodeModel> nodes = await serverCalls.loadAllNodes();

      // categorize nodes by category, type, and task and return them in a 3 level map
      return _categorizeNodes(nodes);
    } catch (e) {
      throw Exception(e);
    }
  }

  Map<String, Map<String, Map<String, List<NodeModel>>>> _categorizeNodes(
      List<NodeModel> nodes) {
    Map<String, Map<String, Map<String, List<NodeModel>>>> categorizedNodes =
        {};

    for (NodeModel node in nodes) {
      // check if the node category, type, and task keys exist and if not, create them
      _createKeysIfNotExist(categorizedNodes, node);

      // Add the node to the list of nodes in the corresponding category, type, and task
      categorizedNodes[node.category]![node.type]![node.task]!.add(node);
    }

    return categorizedNodes;
  }

  void _createKeysIfNotExist(
      Map<String, Map<String, Map<String, List<NodeModel>>>> categorizedNodes,
      NodeModel node) {
    // If the category key does not exist, create it and assign an empty map, else do nothing
    categorizedNodes.putIfAbsent(node.category, () => {});

    // If the type key does not exist, create it
    categorizedNodes[node.category]!.putIfAbsent(node.type, () => {});

    // If the task key does not exist, create it
    categorizedNodes[node.category]![node.type]!
        .putIfAbsent(node.task, () => []);
  }
}

// Example of the returned map:
Map<String, Map<String, Map<String, List<NodeModel>>>> mapScheme = {
  "Models": {
    "linear_models": {
      "regression": [NodeModel(), NodeModel()],
      "classification": [NodeModel()],
      "clustering": [NodeModel()],
    },
    "svm": {
      "regression": [NodeModel(), NodeModel()],
      "classification": [NodeModel()],
      "clustering": [NodeModel()],
    }
  },
};
