import 'package:flutter/material.dart';

import '../../data/vs_interface.dart';

const Color _interfaceColor = Colors.orange;

class VSBoolInputData extends VSInputData {
  ///Basic boolean input interface
  VSBoolInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSBoolOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSBoolOutputData extends VSOutputData<bool> {
  ///Basic boolean output interface
  VSBoolOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
