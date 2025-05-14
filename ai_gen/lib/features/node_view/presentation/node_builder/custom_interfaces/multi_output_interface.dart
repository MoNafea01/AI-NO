import 'package:ai_gen/core/services/app_services.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'interface_colors.dart';

Color _interfaceColor = NodeTypes.general.color;

/// A class to hold shared state for output data
class OutputState {
  bool isRunning = false;
}

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
    required super.type,
    required super.node,
    required this.outputState,
    super.outputFunction,
  });

  final int index;
  final OutputState outputState;

  @override
  Color get interfaceColor => node.color;

  @override
  Future<Map<String, dynamic>> Function(Map<String, dynamic> p1)
      get outputFunction {
    return (inputData) async {
      final AppServices nodeServerCalls = GetIt.I.get<AppServices>();
      if (index == 0) {
        outputState.isRunning = true;

        await Future.delayed(const Duration(seconds: 5));
        await _runNode(inputData, nodeServerCalls);
        outputState.isRunning = false;
      } else {
        int x = 0;
        while (node.nodeId == null) {
          await Future.delayed(const Duration(milliseconds: 100));
          x++;
          if (x % 10 == 0 && !outputState.isRunning) {
            await _runNode(inputData, nodeServerCalls);
          }
        }
      }

      return await nodeServerCalls.getNode(node, index + 1);
    };
  }

  Future<void> _runNode(
      Map<String, dynamic> inputData, AppServices nodeServerCalls) async {
    final Map<String, dynamic> apiBody = {};

    apiBody["params"] = node.paramsToJson;

    for (var input in inputData.entries) {
      apiBody[input.key] = await input.value;
    }

    Map<String, dynamic> response =
        await nodeServerCalls.runNode(node, apiBody);
    node.nodeId = response["node_id"] ?? node.nodeId;
  }
}
