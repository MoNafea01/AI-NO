import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';

Color _interfaceColor = NodeTypes.general.color;

class DataLoaderInputData extends VSInputData {
  ///Basic List input interface
  DataLoaderInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [DataLoaderOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class DataLoaderOutputData extends VSOutputData {
  ///Basic List output interface
  DataLoaderOutputData(
      {required this.node, required super.type, super.outputFunction});

  final NodeModel node;
  @override
  Color get interfaceColor => node.color;
}
