import 'dart:async';

import 'package:ai_gen/features/node_view/data/functions/node_server_calls.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Color _interfaceColor = NodeTypes.preprocessors.color;

class VSPreprocessorInputData extends VSAINOGeneralInputData {
  ///Basic List input interface
  VSPreprocessorInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
  });

  @override
  List<Type> get acceptedTypes => [VSPreprocessorOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
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

      final NodeServerCalls nodeServerCalls = GetIt.I.get<NodeServerCalls>();
      return await nodeServerCalls.runNode(node, apiBody);
    };
  }

  @override
  IconData get outputIcon => Icons.square_sharp;

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => _interfaceColor;
}
