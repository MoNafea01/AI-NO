import 'package:flutter/material.dart';

import '../../data/vs_interface.dart';
import 'vs_num_interface.dart';

const Color _interfaceColor = Colors.blue;

class VSIntInputData extends VSInputData {
  ///Basic int input interface
  VSIntInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSIntOutputData, VSNumOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSIntOutputData extends VSOutputData<int> {
  ///Basic int output interface
  VSIntOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
