import 'dart:async';

import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/node_package/data/custom_interfaces/aino_general_Interface.dart';
import 'package:flutter/material.dart';

class VSPreprocessorInputData extends VSAINOGeneralInputData {
  ///Basic List input interface
  VSPreprocessorInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSPreprocessorOutputData];

  @override
  Color get interfaceColor => NodeColors.modelColor;
}

class VSPreprocessorOutputData extends VSAINOGeneralOutputData {
  ///Basic List output interface
  VSPreprocessorOutputData({
    required super.type,
    required this.block,
  });

  final BlockModel block;

  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get _outputFunction {
    return (Map<String, dynamic> data) async {
      final Map<String, dynamic> apiBody = {
        "node_name": block.nodeName,
        "node_type": block.type,
        "params": block.paramsToJson,
      };

      print(apiBody);

      return await ApiCall().makeAPICall(block.apiCall!, apiData: apiBody);
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => NodeColors.modelColor;
}
