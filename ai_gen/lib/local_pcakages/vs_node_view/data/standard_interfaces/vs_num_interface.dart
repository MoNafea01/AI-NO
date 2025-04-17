import 'package:flutter/material.dart';

import '../../data/vs_interface.dart';
import 'vs_double_interface.dart';
import 'vs_int_interface.dart';

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
