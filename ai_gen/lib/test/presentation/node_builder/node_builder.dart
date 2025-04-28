import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/features/node_view/data/api_services/node_server_calls.dart';
import 'package:ai_gen/features/node_view/data/serialization/node_serializer.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_subgroup.dart';
import 'package:vs_node_view/special_nodes/vs_output_node.dart';

import 'custom_interfaces/aino_general_Interface.dart';
import 'custom_interfaces/model_interface.dart';
import 'custom_interfaces/multi_output_interface.dart';
import 'custom_interfaces/preprocessor_interface.dart';
import 'custom_interfaces/vs_text_input_data.dart';

class NodeBuilder {
  Future<List<Object>> buildNodesMenu() async {
    final Map<String, Map<String, Map<String, List<NodeModel>>>> allNodes =
        await NodeSerializer().categorizeNodes();

    return [
      // output node
      (Offset offset, VSOutputData? ref) => VSOutputNode(
            type: "Scope",
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
      NodeModel newNode = node.copyWith(projectId: 1);
      return VSNodeData(
        type: newNode.name,
        title: newNode.displayName,
        toolTip: newNode.description,
        // menuToolTip: "",
        widgetOffset: offset,
        inputData: _buildInputData(newNode, ref),
        outputData: _buildOutputData(newNode),
        // deleteAction: () {
        //   print("${newNode.name} Deleted");
        //   final NodeServerCalls nodeServerCalls =
        //       GetIt.I.get<NodeServerCalls>();
        //   if (newNode.nodeId != null) nodeServerCalls.deleteNode(newNode);
        // },
      );
    };
  }

  List<VSInputData> _buildInputData(NodeModel node, VSOutputData? ref) {
    return [
      ...node.params?.map(_paramInput) ?? [],
      ...node.inputDots?.map((inputDot) => _inputDots(node, inputDot, ref)) ??
          [],
    ];
  }

  VSInputData _inputDots(
      NodeModel node, String inputDot, VSOutputData<dynamic>? ref) {
    if (inputDot == "model" || inputDot == "fittedModel") {
      return VSModelInputData(type: inputDot, initialConnection: ref);
    }
    if (inputDot == "preprocessor") {
      return VSPreprocessorInputData(type: inputDot, initialConnection: ref);
    }
    return VSAINOGeneralInputData(type: inputDot, initialConnection: ref);
  }

  VSInputData _paramInput(ParameterModel param) {
    final controller = TextEditingController(text: param.value.toString());
    controller.addListener(() => param.value = controller.text);

    return VsTextInputData(type: param.name, controller: controller);
  }

  List<VSOutputData> _buildOutputData(NodeModel node) {
    if (node.outputDots != null && node.outputDots!.length > 1) {
      return multiOutputNodes(node);
    }
    return node.outputDots?.map(
          (outputDot) {
            if (node.category == "Models") {
              return VSModelOutputData(type: outputDot, node: node);
            }
            if (outputDot == "preprocessor") {
              return VSPreprocessorOutputData(type: outputDot, node: node);
            }

            return VSAINOGeneralOutputData(type: outputDot, node: node);
          },
        ).toList() as List<VSOutputData>? ??
        [];
  }

  List<VSOutputData> multiOutputNodes(NodeModel node) {
    Map<String, dynamic>? postResponse;
    final List<VSOutputData> outputData = [];

    for (int i = 0; i < node.outputDots!.length; i++) {
      if (i == 0) {
        outputData.add(
          MultiOutputOutputData(
            type: node.outputDots![i],
            outputFunction: (inputData) async {
              postResponse = null;
              final Map<String, dynamic> apiBody = {};
              if (node.name == "data_loader") {
                apiBody["dataset_name"] = "diabetes";
              } else {
                for (var input in inputData.entries) {
                  apiBody[input.key] = await input.value;
                }
              }
              final NodeServerCalls nodeServerCalls =
                  GetIt.I.get<NodeServerCalls>();
              postResponse = await nodeServerCalls.runNode(node, apiBody);

              node.nodeId = postResponse!["node_id"];
              return await nodeServerCalls.getNode(node, 1);
            },
          ),
        );
        continue;
      }
      outputData.add(
        MultiOutputOutputData(
          type: node.outputDots![i],
          outputFunction: (inputData) async {
            while (postResponse == null) {
              await Future.delayed(const Duration(milliseconds: 100));
            }

            node.id = postResponse!["node_id"];
            final NodeServerCalls nodeServerCalls =
                GetIt.I.get<NodeServerCalls>();
            return await nodeServerCalls.getNode(node, 2);
          },
        ),
      );
    }
    return outputData;
  }
}
