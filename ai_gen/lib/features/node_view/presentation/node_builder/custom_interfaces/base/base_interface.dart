import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class BaseOutputData extends VSOutputData {
  BaseOutputData({
    required super.type,
    required this.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });

  final NodeModel node;

  @override
  Color get interfaceColor => node.color;

  Future<Map<String, dynamic>> runNodeWithData(
    Map<String, dynamic> data,
  ) async {
    final Map<String, dynamic> apiBody = {};
    apiBody["params"] = node.paramsToJson;

    for (var input in data.entries) {
      apiBody[input.key] = await input.value;
    }

    final nodeServices = GetIt.I.get<INodeServices>();
    final response = await nodeServices.runNode(node, apiBody);
    return response;
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      runNodeWithData;
}

abstract class BaseInputData extends VSInputData {
  BaseInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => NodeTypes.general.color;
}
