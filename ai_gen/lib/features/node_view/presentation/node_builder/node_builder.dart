import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/data/functions/node_server_calls.dart';
import 'package:ai_gen/features/node_view/data/serialization/node_serializer.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../main.dart';
import 'custom_interfaces/aino_general_Interface.dart';
import 'custom_interfaces/model_interface.dart';
import 'custom_interfaces/multi_output_interface.dart';
import 'custom_interfaces/preprocessor_interface.dart';

class NodeBuilder {
  Future<List<Object>> buildNodesMenu() async {
    final Map<String, Map<String, Map<String, List<NodeModel>>>> allNodes =
        await NodeSerializer().categorizeNodes();

    return [
      // output node
      (Offset offset, VSOutputData? ref) => VSOutputNode(
            type: "Run",
            widgetOffset: offset,
            ref: ref,
          ),

      ..._buildCategorizedNodes(allNodes),
    ];
  }

  // Nodes Scheme
  // Map<String, Map<String, Map<String, List<NodeModel>>>> mapScheme = {
  //   "Models": {
  //        "linear_models": {
  //                "regression": [NodeModel(), NodeModel()],
  //                "classification": [NodeModel()],
  //          },
  //          "svm": {
  //                "regression": [NodeModel(), NodeModel()],
  //                "classification": [NodeModel()],
  //                "clustering": [NodeModel()],
  //          }
  //   },
  // };

  // first subgroup that contains the types
  List<VSSubgroup> _buildCategorizedNodes(Map<String, Map> allNodes) {
    return _buildSubgroups(allNodes, _buildTypes);
  }

  // second subgroup that contains the tasks
  List<VSSubgroup> _buildTypes(Map<String, Map> nodesCategory) {
    return _buildSubgroups(nodesCategory, _buildTasks);
  }

  // third subgroup that contains the nodes
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

  // build the last List of nodes
  List<Function(Offset, VSOutputData?)> _buildNodes(List<NodeModel> nodesList) {
    return nodesList.map((NodeModel node) => _buildNode(node)).toList();
  }

  //build the node itself
  Function(Offset, VSOutputData?) _buildNode(NodeModel node) {
    return (Offset offset, VSOutputData? ref) {
      NodeModel newNode = node.copyWith();
      return VSNodeData(
        node: newNode,
        type: newNode.name,
        title: newNode.displayName,
        nodeColor: newNode.color,
        toolTip: newNode.description,
        widgetOffset: offset,
        inputData: _buildInputData(newNode, ref),
        outputData: _buildOutputData(newNode),
        deleteNode: () {
          final NodeServerCalls nodeServerCalls =
              GetIt.I.get<NodeServerCalls>();
          if (newNode.nodeId != null) nodeServerCalls.deleteNode(newNode);

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
      return VSModelInputData(type: inputDot, initialConnection: ref);
    }
    if (inputDot == "preprocessor" || inputDot == "fitted_preprocessor") {
      return VSPreprocessorInputData(type: inputDot, initialConnection: ref);
    }
    return VSAINOGeneralInputData(type: inputDot, initialConnection: ref);
  }

  List<VSOutputData> _buildOutputData(NodeModel node) {
    if (node.outputDots == null || node.outputDots!.isEmpty) return [];

    final String outputDot = node.outputDots![0];
    if (node.outputDots!.length > 1) {
      return multiOutputNodes(node);
    }
    if (node.category == "Models") {
      return [VSModelOutputData(type: outputDot, node: node)];
    }
    if (node.category == "Preprocessors") {
      return [VSPreprocessorOutputData(type: outputDot, node: node)];
    }
    if (node.name == "model_fitter" || node.name == "preprocessor_fitter") {
      return [
        VSAINOGeneralOutputData(
          type: outputDot,
          node: node,
          outputIcon: Icons.square_sharp,
        )
      ];
    }
    return [VSAINOGeneralOutputData(type: outputDot, node: node)];
  }

  List<MultiOutputOutputData> multiOutputNodes(NodeModel node) {
    Map<String, dynamic> response = {};
    final List<MultiOutputOutputData> outputData = [];
    for (int i = 0; i < node.outputDots!.length; i++) {
      outputData.add(
        MultiOutputOutputData(
          index: i,
          node: node,
          response: response,
          type: node.outputDots![i],
        ),
      );
    }
    return outputData;
  }
}
