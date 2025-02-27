import 'dart:async';

import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.purple;

class VSMapInputData extends VSInputData {
  ///Basic List input interface
  VSMapInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSMapOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSMapOutputData extends VSOutputData<Map> {
  ///Basic List output interface
  VSMapOutputData({
    required super.type,
    FutureOr<Map<String, dynamic>> Function(Map<String, dynamic>)?
        super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
