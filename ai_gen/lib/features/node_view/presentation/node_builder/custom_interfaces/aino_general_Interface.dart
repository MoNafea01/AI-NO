import 'dart:async';

import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/data/functions/api_call.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

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
      // if (block.nodeName == "data_loader") {
      //   print('data_loader');
      //   return {};
      // }

      print("fitter body: $apiBody");

      var response = await ApiCall().runNode(node, apiData: apiBody);
      print("response: $response");
      return response;
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;

  @override
  Color get interfaceColor => _interfaceColor;
}
