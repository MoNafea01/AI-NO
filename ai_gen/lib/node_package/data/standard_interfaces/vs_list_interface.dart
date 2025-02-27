import 'dart:async';

import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.purple;

class VSListInputData extends VSInputData {
  ///Basic List input interface
  VSListInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSListOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSListOutputData extends VSOutputData<List> {
  ///Basic List output interface
  VSListOutputData({
    required super.type,
    FutureOr<List<double>> Function(Map<String, dynamic>)? super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
