import 'dart:async';

import 'package:ai_gen/core/models/block_model/BlockModel.dart';
import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/node_package/data/custom_interfaces/aino_general_Interface.dart';
import 'package:flutter/material.dart';

class VSModelInputData extends VSAINOGeneralInputData {
  ///Basic List input interface
  VSModelInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSModelOutputData];

  @override
  Color get interfaceColor => NodeColors.modelColor;
}

class VSModelOutputData extends VSAINOGeneralOutputData {
  ///Basic List output interface
  VSModelOutputData({
    required super.type,
    required this.block,
  });

  final BlockModel block;

  Future<dynamic> Function(Map<String, dynamic> data) get _outputFunction {
    return (Map<String, dynamic> data) async {
      final Map<String, dynamic> apiBody = {
        "model_name": block.nodeName,
        "model_type": block.type,
        "task": block.task,
        "params": block.paramsToJson,
      };

      final Map<String, dynamic> x =
          await ApiCall().makeAPICall(block.apiCall!, apiData: apiBody);
      return x["node_id"];
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => NodeColors.modelColor;
}
