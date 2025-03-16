import 'package:ai_gen/features/node_view/data/functions/node_server_calls.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'aino_general_Interface.dart';
import 'interface_colors.dart';

Color _interfaceColor = NodeTypes.models.color;

class VSModelInputData extends VSAINOGeneralInputData {
  ///Basic List input interface
  VSModelInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
  });

  @override
  IconData get connectedInputIcon => Icons.square_rounded;
  @override
  IconData get inputIcon => Icons.square_outlined;

  @override
  List<Type> get acceptedTypes => [VSModelOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSModelOutputData extends VSAINOGeneralOutputData {
  ///Basic List output interface
  VSModelOutputData({required super.type, required super.node});

  @override
  IconData get outputIcon => Icons.square_rounded;

  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get _outputFunction {
    return (Map<String, dynamic> data) async {
      final Map<String, dynamic> apiBody = {
        "model_name": node.name,
        "model_type": node.type,
        "task": node.task,
        "params": node.paramsToJson,
      };
      final NodeServerCalls nodeServerCalls = GetIt.I.get<NodeServerCalls>();
      return await nodeServerCalls.runNode(node, apiBody);
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => node.color;
}
