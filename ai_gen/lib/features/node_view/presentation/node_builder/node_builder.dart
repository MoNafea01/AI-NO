import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/models/block_model/Params.dart';
import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/data/serialization/block_serializer.dart';
import 'package:ai_gen/node_package/custom_widgets/vs_text_input_data.dart';
import 'package:ai_gen/node_package/data/custom_interfaces/general_Interface.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_model_interface.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

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
  List<VSSubgroup> _buildCategories(
      Map<String, Map<String, Map<String, List<BlockModel>>>>
          categorizedBlocks) {
    return categorizedBlocks.entries.map(
      (blockCategory) {
        final String categoryName = blockCategory.key;
        final Map<String, Map<String, List<BlockModel>>> categoryTypes =
            blockCategory.value;

        final List<VSSubgroup> typeTasks = _buildTypes(categoryTypes);
        return VSSubgroup(name: categoryName, subgroup: typeTasks);
      },
    ).toList();
  }

  List<VSSubgroup> _buildTypes(
      Map<String, Map<String, List<BlockModel>>> categorizedBlocks) {
    return categorizedBlocks.entries.map(
      (blockType) {
        final String typeName = blockType.key;
        final Map<String, List<BlockModel>> tasksList = blockType.value;

        final List<VSSubgroup> typeTasks = _buildTasks(tasksList);
        return VSSubgroup(name: typeName, subgroup: typeTasks);
      },
    ).toList();
  }

  List<VSSubgroup> _buildTasks(Map<String, List<BlockModel>> taskMap) {
    return taskMap.entries.map((blockTask) {
      final String taskName = blockTask.key;
      final List<BlockModel> blocksList = blockTask.value;

      final blockNodes = _buildBlockNodes(blocksList);
      return VSSubgroup(name: taskName, subgroup: blockNodes);
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
    return VSModelInputData(type: inputDot, initialConnection: ref);
  }

  VSInputData _paramInput(Params param) {
    return VsTextInputData(
      type: param.name ?? "type",
      controller: TextEditingController(text: param.value.toString()),
    );
  }

  List<VSOutputData> _buildOutputData(BlockModel block) {
    return block.outputDots?.map((outputDot) {
          return VSGeneralOutputData(
            type: "${outputDot}Output",
            outputFunction: (data) async {
              final params = {};

              if (block.params != null) {
                for (var e in block.params!) {
                  params.addAll({e.name!: e.value});
                }
              }
              print("params : $params");

              return await ApiCall().makeAPICall(
                block.apiCall!,
                data: {
                  "model_name": block.nodeName,
                  "model_type": block.type,
                  "task": block.task,
                  "params": params,
                },
              );
            },
          );
        }).toList() ??
        [];
  }
  // List<VSOutputData> _buildOutputData(BlockModel block) {
  //   return block.outputDots?.map((outputDot) {
  //         return VSModelOutputData(
  //           type: "${outputDot}Output",
  //           outputFunction: (data) async {
  //             final aiModel = AIModel(
  //               modelName: block.nodeName,
  //               modelType: block.type,
  //               task: block.task,
  //               params: {},
  //             );
  //
  //             return await apiCall(aiModel.createModelToJson());
  //           },
  //         );
  //       }).toList() ??
  //       [];
  // }
}
