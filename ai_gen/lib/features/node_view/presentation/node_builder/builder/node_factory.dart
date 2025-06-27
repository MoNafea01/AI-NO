import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/network_interface.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../custom_interfaces/aino_general_interface.dart';
import '../custom_interfaces/model_interface.dart';
import '../custom_interfaces/multi_output_interface.dart';
import '../custom_interfaces/node_loader_interface.dart';
import '../custom_interfaces/node_template_saver_interface.dart';
import '../custom_interfaces/preprocessor_interface.dart';

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

  List<VSInputData> _buildInputData(NodeModel node, VSOutputData? ref) {
    return [
      ...node.inputDots?.map((inputDot) => _inputDots(node, inputDot, ref)) ??
          [],
    ];
  }

  VSInputData _inputDots(
      NodeModel node, String inputDot, VSOutputData<dynamic>? ref) {
    if (inputDot == "model" || inputDot == "fitted_model") {
      return VSModelInputData(
          type: inputDot, initialConnection: ref, node: node);
    }
    if (inputDot == "preprocessor" || inputDot == "fitted_preprocessor") {
      return VSPreprocessorInputData(
          type: inputDot, initialConnection: ref, node: node);
    }
    if (node.name == "node_template_saver") {
      return VSNodeTemplateSaverInputData(
          type: inputDot, initialConnection: ref, node: node);
    }
    return VSAINOGeneralInputData(
        type: inputDot, initialConnection: ref, node: node);
  }

  List<VSOutputData> _buildOutputData(NodeModel node) {
    if (node.outputDots == null || node.outputDots!.isEmpty) return [];
    final String outputDot = node.outputDots![0];
    if (node.outputDots!.length > 1) {
      return _multiOutputNodes(node);
    }
    if (node.category == "Models") {
      return [VSModelOutputData(type: outputDot, node: node)];
    }
    if (node.category == "Preprocessors") {
      return [VSPreprocessorOutputData(type: outputDot, node: node)];
    }
    if (node.category == "Network") {
      return [VSNetworkOutputData(type: outputDot, node: node)];
    }
    if (node.name == "model_fitter" || node.name == "preprocessor_fitter") {
      return [
        VSFitterOutputData(
          type: outputDot,
          node: node,
          outputIcon: Icons.square_sharp,
        )
      ];
    }
    if (node.name == "node_template_saver") {
      return [VSNodeTemplateSaverOutputData(type: outputDot, node: node)];
    }
    if (node.name == "node_loader") {
      return [VSNodeLoaderOutputData(type: outputDot, node: node)];
    }
    return [VSAINOGeneralOutputData(type: outputDot, node: node)];
  }

  List<MultiOutputOutputData> _multiOutputNodes(NodeModel node) {
    final List<MultiOutputOutputData> outputData = [];
    final outputState = OutputState();
    for (int i = 0; i < node.outputDots!.length; i++) {
      outputData.add(
        MultiOutputOutputData(
          index: i,
          node: node,
          type: node.outputDots![i],
          outputState: outputState,
        ),
      );
    }
    return outputData;
  }
}
