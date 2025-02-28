import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/models/block_model/Params.dart';
import 'package:ai_gen/features/node_view/data/serialization/block_serializer.dart';
import 'package:ai_gen/node_package/custom_widgets/vs_text_input_data.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_model_interface.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

import 'custom_interfaces/model_interface.dart';

class NodeBuilder {
  Future<List<Object>> buildBlocks() async {
    final Map<String, Map<String, Map<String, List<BlockModel>>>>
        categorizedBlocks = await BlockSerializer().categorizeBlocks();

    return [
      // output node
      (Offset offset, VSOutputData? ref) => VSOutputNode(
            type: "Evaluate",
            widgetOffset: offset,
            ref: ref,
          ),
      ..._buildCategories(categorizedBlocks),
    ];
  }

  // Blocks Scheme
  // Map<String, Map<String, Map<String, List<BlockModel>>>> mapScheme = {
  //   "Models": {
  //     "linear_models": {
  //       "regression": [BlockModel(), BlockModel()],
  //       "classification": [BlockModel()],
  //       "clustering": [BlockModel()],
  //     },
  //     "svm": {
  //       "regression": [BlockModel(), BlockModel()],
  //       "classification": [BlockModel()],
  //       "clustering": [BlockModel()],
  //     }
  //   },
  // };

  List<VSSubgroup> _buildCategories(Map<String, Map> blocksMap) {
    return _buildSubgroups(blocksMap, _buildTypes);
  }

  List<VSSubgroup> _buildTypes(Map<String, Map> categorizedBlocks) {
    return _buildSubgroups(categorizedBlocks, _buildTasks);
  }

  List<VSSubgroup> _buildTasks(Map<String, List<BlockModel>> taskMap) {
    return _buildSubgroups(taskMap, _buildBlockNodes);
  }

  List<VSSubgroup> _buildSubgroups(
      Map<String, dynamic> blocksCategory, Function buildFunction) {
    return blocksCategory.entries.map((entry) {
      final name = entry.key;
      final value = entry.value;
      final subgroups = buildFunction(value);
      return VSSubgroup(name: name, subgroup: subgroups);
    }).toList();
  }

  List<Function(Offset, VSOutputData?)> _buildBlockNodes(
      List<BlockModel> blocksList) {
    return blocksList.map((BlockModel block) {
      return (Offset offset, VSOutputData? ref) => VSNodeData(
            type: block.nodeName!,
            widgetOffset: offset,
            inputData: _buildInputData(block, ref),
            outputData: _buildOutputData(block),
          );
    }).toList();
  }

  List<VSInputData> _buildInputData(BlockModel block, VSOutputData? ref) {
    return [
      ...block.params?.map(_paramInput) ?? [],
      ...block.inputDots?.map((inputDot) => _inputDots(inputDot, ref)) ?? [],
    ];
  }

  VSInputData _inputDots(String inputDot, VSOutputData<dynamic>? ref) {
    return VSOldModelInputData(type: inputDot, initialConnection: ref);
  }

  VSInputData _paramInput(Params param) {
    final controller = TextEditingController(text: param.value.toString());
    controller.addListener(() => param.value = controller.text);

    return VsTextInputData(type: param.name, controller: controller);
  }

  List<VSOutputData> _buildOutputData(BlockModel block) {
    if (block.category == "Models" && block.outputDots?.length == 1) {
      return [
        VSModelOutputData(type: "${block.outputDots![0]}Output", block: block),
      ];
    }
    return block.outputDots?.map((outputDot) {
          return VSModelOutputData(type: "${outputDot}Output", block: block);
        }).toList() ??
        [];
  }
}
