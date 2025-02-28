import 'dart:async';

import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.blue;

class VSAINOGeneralInputData extends VSInputData {
  ///Basic List input interface
  VSAINOGeneralInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSAINOGeneralOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSAINOGeneralOutputData extends VSOutputData {
  ///Basic List output interface
  VSAINOGeneralOutputData({
    required super.type,
    FutureOr Function(Map<String, dynamic> data)? super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
