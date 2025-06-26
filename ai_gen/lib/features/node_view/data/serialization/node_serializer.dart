import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/network/services/interfaces/node_services_interface.dart';
import 'package:get_it/get_it.dart';

class NodeSerializer {
  static Map<int, NodeModel> nodesDictionary = {};

  Future<Map<String, Map<String, Map<String, List<NodeModel>>>>>
      categorizeNodes() async {
    try {
      INodeServices serverCalls = GetIt.I.get<INodeServices>();
      // read the nodes from the server
      nodesDictionary = await serverCalls.loadNodesComponents();

      List<NodeModel> nodes = nodesDictionary.values.toList();

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

      // get the showing order of the node
      int length =
          categorizedNodes[node.category]![node.type]![node.task]!.length;
      node.order = length + 1;

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
// Map<String, Map<String, Map<String, List<NodeModel>>>> mapScheme = {
//   "Models": {
//     "linear_models": {
//       "regression": [NodeModel(), NodeModel()],
//       "classification": [NodeModel()],
//       "clustering": [NodeModel()],
//     },
//     "svm": {
//       "regression": [NodeModel(), NodeModel()],
//       "classification": [NodeModel()],
//       "clustering": [NodeModel()],
//     }
//   },
// };
