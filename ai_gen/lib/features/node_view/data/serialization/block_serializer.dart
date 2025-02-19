import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:dio/dio.dart';

class BlockSerializer {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsApi = NetworkConstants.allComponentsApi;

  final Dio dio = Dio();

  Future<List<BlockModel>> _serializeBlocks() async {
    try {
      final Response response = await dio.get("$_baseURL/$_allComponentsApi");
      List<BlockModel> blocks = [];

      if (response.statusCode == 200) {
        if (response.data != null) {
          response.data.forEach((blockData) {
            BlockModel blockModel = BlockModel.fromJson(blockData);
            blocks.add(blockModel);
          });

          return blocks;
        } else {
          throw Exception('server error: response data is null');
        }
      } else {
        throw Exception("server error: error code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Server Error: $e");
    }
  }

  Future<Map<String, Map<String, List<BlockModel>>>> getBlocks() async {
    try {
      List<BlockModel> blocks = await _serializeBlocks();
      Map<String, Map<String, List<BlockModel>>> categorizedBlocks = {};

      for (BlockModel block in blocks) {
        if (categorizedBlocks.containsKey(block.nodeType)) {
          if (categorizedBlocks[block.nodeType]!.containsKey(block.task)) {
            categorizedBlocks[block.nodeType]![block.task!]!.add(block);
          } else {
            categorizedBlocks[block.nodeType]![block.task!] = [block];
          }
        } else {
          categorizedBlocks[block.nodeType!] = {
            block.task!: [block]
          };
        }
      }
      return categorizedBlocks;
    } catch (e) {
      throw Exception(e);
    }
  }
}

// Example of the returned map:
Map<String, Map<String, List<BlockModel>>> mapScheme = {
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
};
