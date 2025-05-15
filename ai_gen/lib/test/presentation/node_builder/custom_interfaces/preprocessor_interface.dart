import 'dart:async';

import 'package:ai_gen/core/services/interfaces/node_services_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'aino_general_Interface.dart';
import 'interface_colors.dart';

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
    required super.node,
  });

  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get _outputFunction {
    return (Map<String, dynamic> data) async {
      final Map<String, dynamic> apiBody = {
        "preprocessor_name": node.name,
        "preprocessor_type": node.type,
        "params": node.paramsToJson,
      };
      final INodeServices nodeServerCalls = GetIt.I.get<INodeServices>();
      return await nodeServerCalls.runNode(node, apiBody);
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => NodeColors.modelColor;
}
