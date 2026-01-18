import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';

import '../../../../../main.dart';
import 'interface_factory.dart';

/// Responsible for instantiating node widgets/data from NodeModel.
class NodeFactory {
  NodeFactory({required this.projectId});
  final int projectId;

  /// The function to create the output node (Run node).
  VSOutputNode runNode(Offset offset, VSOutputData? ref) => VSOutputNode(
        type: "Run",
        widgetOffset: offset,
        ref: ref,
      );

  /// Returns a function that builds a VSNodeData for a given NodeModel.
  Function(Offset, VSOutputData?) buildNode(NodeModel node) {
    return (Offset offset, VSOutputData? ref) {
      NodeModel newNode = node.copyWith(projectId: projectId);
      return VSNodeData(
        id: newNode.nodeId?.toString(),
        node: newNode,
        type: newNode.name,
        title: newNode.displayName,
        nodeColor: newNode.color,
        toolTip: newNode.description,
        widgetOffset: offset,
        inputData: _buildInputData(newNode, ref),
        outputData: _buildOutputData(newNode),
        deleteNode: () {
          scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text("${node.displayName} deleted"),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      );
    };
  }

  /// Builds input data interfaces using the InterfaceFactory.
  List<VSInputData> _buildInputData(NodeModel node, VSOutputData? ref) {
    return [
      ...node.inputDots?.map((inputDot) {
            return InterfaceFactory.createInputData(node, inputDot, ref);
          }).toList() ??
          [],
    ];
  }

  /// Builds output data interfaces using the InterfaceFactory.
  List<VSOutputData> _buildOutputData(NodeModel node) {
    return InterfaceFactory.createOutputData(node);
  }
}
