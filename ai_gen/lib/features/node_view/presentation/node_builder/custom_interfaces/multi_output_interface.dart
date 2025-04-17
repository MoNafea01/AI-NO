import 'package:ai_gen/features/node_view/data/functions/node_server_calls.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'interface_colors.dart';

Color _interfaceColor = NodeTypes.general.color;

class MultiOutputInputInterface extends VSAINOGeneralInputData {
  ///Basic List input interface
  MultiOutputInputInterface({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [MultiOutputOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class MultiOutputOutputData extends VSAINOGeneralOutputData {
  ///Basic List output interface
  MultiOutputOutputData({
    required this.index,
    required this.response,
    required super.type,
    required super.node,
    super.outputFunction,
  });

  final int index;
  Map<String, dynamic> response;

  @override
  Color get interfaceColor => node.color;

  @override
  Future<Map<String, dynamic>> Function(Map<String, dynamic> p1)
      get outputFunction {
    return (inputData) async {
      final NodeServerCalls nodeServerCalls = GetIt.I.get<NodeServerCalls>();
      if (index == 0) {
        // response = null;
        final Map<String, dynamic> apiBody = {};

        if (node.name == "data_loader") {
          apiBody["params"] = {"dataset_name": "diabetes"};
        } else {
          for (var input in inputData.entries) {
            apiBody[input.key] = await input.value;
          }
        }
        response = await nodeServerCalls.runNode(node, apiBody);
        node.nodeId = response["node_id"] ?? "Null ID";
      } else {
        while (node.nodeId == null) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      return await nodeServerCalls.getNode(node, index + 1);
    };
  }
}
