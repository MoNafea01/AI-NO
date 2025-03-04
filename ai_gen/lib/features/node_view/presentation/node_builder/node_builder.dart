import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/models/block_model/Params.dart';
import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/data/serialization/block_serializer.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/preprocessor_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/vs_text_input_data.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

import 'custom_interfaces/model_interface.dart';
import 'custom_interfaces/multi_output_interface.dart';

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
    List<VSSubgroup> buildTasks(Map<String, List<BlockModel>> taskMap) {
      return _buildSubgroups(taskMap, _buildBlockNodes);
    }

    List<VSSubgroup> buildTypes(Map<String, Map> categorizedBlocks) {
      return _buildSubgroups(categorizedBlocks, buildTasks);
    }

    return _buildSubgroups(blocksMap, buildTypes);
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
    if (inputDot == "model" || inputDot == "fittedModel") {
      return VSModelInputData(type: inputDot, initialConnection: ref);
    }
    if (inputDot == "preprocessor") {
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
    // if (block.nodeName == "data_loader") {
    //   return dataLoader(block);
    // }
    if (block.outputDots != null && block.outputDots!.length > 1) {
      return multiOutputNodes(block);
    }
    return block.outputDots?.map(
          (outputDot) {
            if (block.category == "Models") {
              return VSModelOutputData(type: outputDot, block: block);
            }
            if (outputDot == "preprocessor") {
              return VSPreprocessorOutputData(type: outputDot, block: block);
            }

            return VSAINOGeneralOutputData(type: outputDot, block: block);
          },
        ).toList() ??
        [];
  }

  List<VSOutputData> multiOutputNodes(BlockModel block) {
    Map<String, dynamic>? postResponse;
    final List<VSOutputData> outputData = [];

    for (int i = 0; i < block.outputDots!.length; i++) {
      if (i == 0) {
        outputData.add(
          MultiOutputOutputData(
            type: block.outputDots![i],
            outputFunction: (inputData) async {
              postResponse = null;
              final Map<String, dynamic> apiBody = {};
              if (block.nodeName == "data_loader") {
                apiBody["dataset_name"] = "diabetes";
              } else {
                for (var input in inputData.entries) {
                  apiBody[input.key] = await input.value;
                }
              }

              postResponse =
                  await ApiCall().postAPICall(block.apiCall!, apiData: apiBody);

              dynamic nodeId = postResponse!["node_id"];
              return await ApiCall()
                  .getAPICall("${block.apiCall!}?node_id=$nodeId&output=1");
            },
          ),
        );
        continue;
      }
      outputData.add(
        MultiOutputOutputData(
          type: block.outputDots![i],
          outputFunction: (inputData) async {
            while (postResponse == null) {
              await Future.delayed(const Duration(milliseconds: 100));
            }

            dynamic nodeId = postResponse!["node_id"];
            return await ApiCall().getAPICall(
              "${block.apiCall!}?node_id=$nodeId&output=2",
            );
          },
        ),
      );
    }
    return outputData;
  }
}
