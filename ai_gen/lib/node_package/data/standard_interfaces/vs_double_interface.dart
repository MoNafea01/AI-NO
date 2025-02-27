import 'package:ai_gen/node_package/data/standard_interfaces/vs_num_interface.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.red;

class VSDoubleInputData extends VSInputData {
  ///Basic double input interface
  VSDoubleInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSDoubleOutputData, VSNumOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSDoubleOutputData extends VSOutputData<double> {
  ///Basic double output interface
  VSDoubleOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
