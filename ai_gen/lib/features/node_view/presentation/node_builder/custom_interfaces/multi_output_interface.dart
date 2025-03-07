import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = NodeColors.functionColor;

class MultiOutputInputInterface extends VSInputData {
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

class MultiOutputOutputData extends VSDynamicOutputData {
  ///Basic List output interface
  MultiOutputOutputData({required super.type, super.outputFunction});

  @override
  Color get interfaceColor => _interfaceColor;
}
