import 'dart:async';

import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
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
  VSModelOutputData({required super.type, required super.node});

  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get _outputFunction {
    return (Map<String, dynamic> data) async {
      final Map<String, dynamic> apiBody = {
        "model_name": node.name,
        "model_type": node.type,
        "task": node.task,
        "params": node.paramsToJson,
      };

      return await ApiCall().runNode(node, apiBody);
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => NodeColors.modelColor;
}
