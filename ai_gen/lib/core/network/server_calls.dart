import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:dio/dio.dart';

import 'network_constants.dart';

class ServerCalls {
  final String _baseURL = NetworkConstants.baseURL;
  final String _allComponentsApi = NetworkConstants.allComponentsApi;

  final Dio dio = Dio();

  Future<List<BlockModel>> getBlocks() async {
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
}
