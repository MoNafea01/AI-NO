import 'dart:async';

import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.blue;

class VSGeneralInputData extends VSInputData {
  ///Basic List input interface
  VSGeneralInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSGeneralOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSGeneralOutputData extends VSOutputData {
  ///Basic List output interface
  VSGeneralOutputData({
    required super.type,
    FutureOr Function(Map<String, dynamic> data)? super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
