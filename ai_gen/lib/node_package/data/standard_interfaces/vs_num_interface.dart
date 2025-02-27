import 'package:ai_gen/node_package/data/standard_interfaces/vs_double_interface.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_int_interface.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.purple;

class VSNumInputData extends VSInputData {
  ///Basic num input interface
  VSNumInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [
        VSDoubleOutputData,
        VSIntOutputData,
        VSNumOutputData,
      ];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSNumOutputData extends VSOutputData<num> {
  ///Basic num output interface
  VSNumOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
