import 'dart:async';

import 'package:ai_gen/core/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'base/base_interface.dart';
import 'network_interface.dart';

class VSPreprocessorInputData extends BaseInputData {
  ///Basic List input interface
  VSPreprocessorInputData({
    required super.type,
    required super.node,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.connectedInputIcon,
  });

  @override
  List<Type> get acceptedTypes =>
      [VSPreprocessorOutputData, VSFitterOutputData, VSNetworkOutputData];

  @override
  // implement inputIcon
  IconData get inputIcon => Icons.square_outlined;

  @override
  IconData get connectedInputIcon => Icons.square_rounded;
}

class VSPreprocessorOutputData extends BaseOutputData {
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

      final nodeServerCalls = GetIt.I.get<INodeServices>();
      return await nodeServerCalls.runNode(node, apiBody);
    };
  }

  @override
  IconData get outputIcon => Icons.square_sharp;

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => node.color;
}
