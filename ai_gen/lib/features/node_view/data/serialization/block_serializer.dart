import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/network/server_calls.dart';

class BlockSerializer {
  Future<Map<String, Map<String, Map<String, List<BlockModel>>>>>
      categorizeBlocks() async {
    try {
      // read the blocks from the server
      List<BlockModel> blocks = await ServerCalls().getBlocks();

      // categorize blocks by category, type, and task and return them in a 3 level map
      return _categorizeBlocks(blocks);
    } catch (e) {
      throw Exception(e);
    }
  }

  Map<String, Map<String, Map<String, List<BlockModel>>>> _categorizeBlocks(
      List<BlockModel> blocks) {
    Map<String, Map<String, Map<String, List<BlockModel>>>> categorizedBlocks =
        {};

    for (BlockModel block in blocks) {
      // check if the block category, type, and task keys exist and if not, create them
      _createKeysIfNotExist(categorizedBlocks, block);

      // Add the block to the list of blocks in the corresponding category, type, and task
      categorizedBlocks[block.category]![block.type]![block.task]!.add(block);
    }

    return categorizedBlocks;
  }

  void _createKeysIfNotExist(
      Map<String, Map<String, Map<String, List<BlockModel>>>> categorizedBlocks,
      BlockModel block) {
    // If the category key does not exist, create it and assign an empty map, else do nothing
    categorizedBlocks.putIfAbsent(block.category, () => {});

    // If the type key does not exist, create it
    categorizedBlocks[block.category]!.putIfAbsent(block.type, () => {});

    // If the task key does not exist, create it
    categorizedBlocks[block.category]![block.type]!
        .putIfAbsent(block.task, () => []);
  }
}

// Example of the returned map:
Map<String, Map<String, Map<String, List<BlockModel>>>> mapScheme = {
  "Models": {
    "linear_models": {
      "regression": [BlockModel(), BlockModel()],
      "classification": [BlockModel()],
      "clustering": [BlockModel()],
    },
    "svm": {
      "regression": [BlockModel(), BlockModel()],
      "classification": [BlockModel()],
      "clustering": [BlockModel()],
    }
  },
};
