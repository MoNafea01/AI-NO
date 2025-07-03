import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/network/services/interfaces/node_services_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vs_node_view/data/vs_interface.dart';

import 'interface_colors.dart';

const Color _interfaceColor = NodeColors.generalColor;

class VSAINOGeneralInputData extends VSInputData {
  ///Basic List input interface
  VSAINOGeneralInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [];

  // to accept all types (like the evaluate node)
  @override
  bool acceptInput(VSOutputData? data) => true;

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSAINOGeneralOutputData extends VSOutputData {
  ///Basic List output interface
  VSAINOGeneralOutputData(
      {required super.type, required this.node, super.outputFunction});

  final NodeModel node;
  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get _outputFunction {
    return (data) async {
      print("\nNode name: ${node.name}");
      final Map<String, dynamic> apiBody = {};
      for (var input in data.entries) {
        apiBody[input.key] = await input.value;
      }

      final INodeServices nodeServerCalls = GetIt.I.get<INodeServices>();
      Map<String, dynamic> response =
          await nodeServerCalls.runNode(node, apiBody);
      return response;
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => _interfaceColor;
}
