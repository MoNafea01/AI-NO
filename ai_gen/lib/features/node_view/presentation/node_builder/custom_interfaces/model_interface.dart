import 'package:ai_gen/core/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'base/base_interface.dart';
import 'network_interface.dart';

class VSModelInputData extends BaseInputData {
  ///Basic List input interface
  VSModelInputData({
    required super.type,
    required super.node,
    super.title,
    super.toolTip,
    super.initialConnection,
  });

  @override
  IconData get connectedInputIcon => Icons.square_rounded;
  @override
  IconData get inputIcon => Icons.square_outlined;

  @override
  List<Type> get acceptedTypes =>
      [VSModelOutputData, VSNetworkOutputData, VSFitterOutputData];
}

class VSModelOutputData extends BaseOutputData {
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

      final INodeServices nodeServerCalls = GetIt.I.get<INodeServices>();
      return await nodeServerCalls.runNode(node, apiBody);
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;
}
