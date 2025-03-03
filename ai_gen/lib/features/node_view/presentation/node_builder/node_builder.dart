import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/models/block_model/Params.dart';
import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/data/serialization/block_serializer.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/preprocessor_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/vs_text_input_data.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

import 'custom_interfaces/data_loader_interface.dart';
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
      if (block.nodeName == "data_loader")
        ...block.params?.map(_paramInput) ?? [],
      ...block.inputDots?.map((inputDot) => _inputDots(block, inputDot, ref)) ??
          [],
    ];
  }

  VSInputData _inputDots(
      BlockModel block, String inputDot, VSOutputData<dynamic>? ref) {
    if (inputDot == "model") {
      return VSModelInputData(type: inputDot, initialConnection: ref);
    }
    return VSAINOGeneralInputData(type: inputDot, initialConnection: ref);
  }

  VSInputData _paramInput(Params param) {
    final controller = TextEditingController(text: param.value.toString());
    controller.addListener(() => param.value = controller.text);

    return VsTextInputData(type: param.name, controller: controller);
  }

  List<VSOutputData> _buildOutputData(BlockModel block) {
    if (block.nodeName == "data_loader") {
      Map<String, dynamic>? postResponse;
      return [
        DataLoaderOutputData(
          type: "X",
          outputFunction: (p0) async {
            postResponse =
                await ApiCall().makeAPICall(block.apiCall!, apiData: {});
            final xResponse = postResponse;
            xResponse!["node_id"];
            return xResponse;
          },
        ),
        DataLoaderOutputData(
          type: "Y",
          outputFunction: (p0) async {
            while (postResponse == null) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
            final yResponse = postResponse;

            yResponse!["node_id"];
            return yResponse;
          },
        )
      ];
    }
    return block.outputDots?.map(
          (outputDot) {
            if (outputDot == "model") {
              return VSModelOutputData(type: outputDot, block: block);
            }
            if (outputDot == "preprocessor") {
              return VSPreprocessorOutputData(type: outputDot, block: block);
            }

            return VSAINOGeneralOutputData(
                type: "$outputDot Output", block: block);
          },
        ).toList() ??
        [];
  }
}
