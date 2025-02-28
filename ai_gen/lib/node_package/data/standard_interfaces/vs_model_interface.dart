import 'dart:async';

import 'package:ai_gen/core/classes/model_class.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.blue;

class VSOldModelInputData extends VSInputData {
  ///Basic List input interface
  VSOldModelInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSOldModelOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSOldModelOutputData extends VSOutputData<AIModel> {
  ///Basic List output interface
  VSOldModelOutputData({
    required super.type,
    FutureOr<AIModel> Function(Map<String, dynamic> data)? super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
