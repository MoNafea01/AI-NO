import 'dart:async';

import 'package:ai_gen/core/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'network_interface.dart';

Color _interfaceColor = NodeTypes.preprocessors.color;

class VSPreprocessorInputData extends VSAINOGeneralInputData {
  ///Basic List input interface
  VSPreprocessorInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.connectedInputIcon,
  });

  @override
  List<Type> get acceptedTypes =>
      [VSPreprocessorOutputData, VSFitterOutputData, VSNetworkOutputData];

  @override
  // TODO: implement inputIcon
  IconData get inputIcon => Icons.square_outlined;

  @override
  IconData get connectedInputIcon => Icons.square_rounded;

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
