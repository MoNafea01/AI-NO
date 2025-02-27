import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.green;

class VSStringInputData extends VSInputData {
  ///Basic String input interface
  VSStringInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSStringOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSStringOutputData extends VSOutputData<String> {
  ///Basic String output interface
  VSStringOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
