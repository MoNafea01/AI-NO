import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/features/node_view/data/serialization/block_serializer.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

class NodeBuilder {
  Future<List<VSSubgroup>> buildBlocks() async {
    final Map<String, Map<String, List<BlockModel>>> categorizedBlocks =
        await _getCategorizedBlocks();

    return _buildBlocks(categorizedBlocks);
  }

  Future<Map<String, Map<String, List<BlockModel>>>>
      _getCategorizedBlocks() async {
    List<BlockModel> blocks = await BlockSerializer().serializeBlocks();
    Map<String, Map<String, List<BlockModel>>> categorizedBlocks = {};

    for (BlockModel block in blocks) {
      if (categorizedBlocks.containsKey(block.nodeType)) {
        if (categorizedBlocks[block.nodeType]!.containsKey(block.task)) {
          categorizedBlocks[block.nodeType]![block.task!]!.add(block);
        } else {
          categorizedBlocks[block.nodeType]![block.task!] != [block];
        }
      } else {
        categorizedBlocks[block.nodeType!] = {
          block.task!: [block],
        };
      }
    }
    return categorizedBlocks;
  }

  List<VSSubgroup> _buildBlocks(
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
    return blocksList.map((block) {
      return (Offset offset, VSOutputData? ref) => VSNodeData(
            type: block.nodeName!,
            widgetOffset: offset,
            inputData: _buildInputData(block.inputDots, ref),
            outputData: _buildOutputData(block.outputDots),
          );
    }).toList();
  }

  List<VSNumInputData> _buildInputData(
      List<String>? inputDots, VSOutputData? ref) {
    return inputDots?.map((inputDot) {
          return VSNumInputData(type: inputDot, initialConnection: ref);
        }).toList() ??
        [];
  }

  List<VSBoolOutputData> _buildOutputData(List<String>? outputDots) {
    return outputDots?.map((outputDot) {
          return VSBoolOutputData(
            type: outputDot,
            outputFunction: (data) => data["First"] > data["Second"],
          );
        }).toList() ??
        [];
  }
}
//{id: 166, node_name: linear_regression, node_type: linear_models, task: regression, params: null, input_dots: [], output_dots: [model], api_call: create_model/}
