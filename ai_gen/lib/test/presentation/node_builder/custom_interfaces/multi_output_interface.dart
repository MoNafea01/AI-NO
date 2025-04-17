import 'package:flutter/material.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:vs_node_view/data/vs_interface.dart';

import 'interface_colors.dart';

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
