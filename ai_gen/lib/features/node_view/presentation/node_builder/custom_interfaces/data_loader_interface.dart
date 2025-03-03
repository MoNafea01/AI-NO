import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = NodeColors.generalColor;

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
  DataLoaderOutputData({required super.type, super.outputFunction});

  @override
  Color get interfaceColor => _interfaceColor;
}
