import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:dio/dio.dart';

class BlockSerializer {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsApi = NetworkConstants.allComponentsApi;

  final Dio dio = Dio();
  Future<List<BlockModel>> serializeBlocks() async {
    try {
      final Response response = await dio.get("$_baseURL/$_allComponentsApi");
      List<BlockModel> blocks = [];

      if (response.statusCode == 200) {
        if (response.data != null) {
          response.data.forEach((blockData) {
            BlockModel blockModel = BlockModel.fromJson(blockData);
            blocks.add(blockModel);
          });

          for (var block in blocks) {
            print(block.toJson());
          }
          return blocks;
        } else {
          throw Exception('Failed to load blocks');
        }
      } else {
        throw Exception('Failed to load blocks');
      }
    } catch (e) {
      throw Exception("Server Error: $e");
    }
  }
}
