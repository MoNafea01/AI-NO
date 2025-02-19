import 'package:ai_gen/core/classes/model_class.dart';
import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/models/block_model/Params.dart';
import 'package:ai_gen/features/node_view/data/functions/create_model.dart';
import 'package:ai_gen/features/node_view/data/serialization/block_serializer.dart';
import 'package:ai_gen/node_package/custom_widgets/vs_text_input_data.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_model_interface.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

class NodeBuilder {
  Future<List<Object>> buildBlocks() async {
    final Map<String, Map<String, List<BlockModel>>> categorizedBlocks =
        await BlockSerializer().getBlocks();

    return [
      // output node
      (Offset offset, VSOutputData? ref) => VSOutputNode(
            type: "Output",
            widgetOffset: offset,
            ref: ref,
          ),
      ..._buildTypes(categorizedBlocks),
    ];
  }

  // Blocks Scheme
  // Map<String, Map<String, List<BlockModel>>> mapScheme = {
  //   "linear_models": {
  //     "regression": [BlockModel(), BlockModel()],
  //     "classification": [BlockModel()],
  //     "clustering": [BlockModel()],
  //   },
  //   "svm": {
  //     "regression": [BlockModel(), BlockModel()],
  //     "classification": [BlockModel()],
  //     "clustering": [BlockModel()],
  //   }
  // };
  List<VSSubgroup> _buildTypes(
      Map<String, Map<String, List<BlockModel>>> categorizedBlocks) {
    return categorizedBlocks.entries.map(
      (blockType) {
        final String typeName = blockType.key;
        final List<VSSubgroup> typeTasks = _buildTasks(blockType.value);

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
      controller: TextEditingController(text: param.defaultValue.toString()),
    );
  }

  List<VSOutputData> _buildOutputData(BlockModel block) {
    return block.outputDots?.map((outputDot) {
          return VSModelOutputData(
            type: "${outputDot}Output",
            outputFunction: (data) async {
              print(data.entries);
              // print("outputFunction: ${data.entries}");
              final aiModel = AIModel(
                modelName: block.nodeName,
                modelType: block.nodeType,
                task: block.task,
                params: {},
              );

              return await apiCall(aiModel.createModelToJson());
            },
          );
        }).toList() ??
        [];
  }
}
