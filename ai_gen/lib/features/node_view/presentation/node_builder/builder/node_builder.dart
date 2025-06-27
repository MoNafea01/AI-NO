import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/data/serialization/node_serializer.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';

import 'node_factory.dart';

/// Builds the menu structure for nodes, using a provided NodeFactory for instantiation.
class NodeMenuBuilder {
  NodeMenuBuilder({required this.projectId})
      : factory = NodeFactory(projectId: projectId);
  final int projectId;
  final NodeFactory factory;

  /// Builds the menu for all nodes, returning a list of menu items and the run node.
  Future<List<Object>> buildNodesMenu() async {
    final Map<String, Map<String, Map<String, List<NodeModel>>>> allNodes =
        await NodeSerializer().categorizeNodes();
    return [
      factory.runNode,
      ..._buildCategorizedNodes(allNodes),
    ];
  }

  List<VSSubgroup> _buildCategorizedNodes(Map<String, Map> allNodes) {
    return _buildSubgroups(allNodes, _buildTypes);
  }

  List<VSSubgroup> _buildTypes(Map<String, Map> nodesCategory) {
    return _buildSubgroups(nodesCategory, _buildTasks);
  }

  List<VSSubgroup> _buildTasks(Map<String, List<NodeModel>> nodesType) {
    return _buildSubgroups(nodesType, _buildNodes);
  }

  List<VSSubgroup> _buildSubgroups(
    Map<String, dynamic> category,
    Function group,
  ) {
    return category.entries.map((entry) {
      final String name = entry.key;
      final List<dynamic> subgroup = group(entry.value);
      return VSSubgroup(name: name, subgroup: subgroup);
    }).toList();
  }

  List<Function(Offset, VSOutputData?)> _buildNodes(List<NodeModel> nodesList) {
    return nodesList.map((NodeModel node) {
      return factory.buildNode(node);
    }).toList();
  }
}
