import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/data/functions/node_server_calls.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'interface_colors.dart';
import 'multi_output_interface.dart';

Color _interfaceColor = NodeTypes.general.color;

class VSNetworkInputData extends VSInputData {
  ///Basic List input interface
  VSNetworkInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSNetworkOutputData, MultiOutputOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSNetworkOutputData extends VSOutputData {
  ///Basic List output interface
  VSNetworkOutputData({
    required super.type,
    required this.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });

  final NodeModel node;
  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get _outputFunction {
    return (data) async {
      print("\nNode name: ${node.name}");
      final Map<String, dynamic> apiBody = {};
      for (var input in data.entries) {
        apiBody[input.key] = await input.value;
      }

      final NodeServerCalls nodeServerCalls = GetIt.I.get<NodeServerCalls>();
      Map<String, dynamic> response =
          await nodeServerCalls.runNode(node, {"params": apiBody});
      return response;
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => node.color;
}
