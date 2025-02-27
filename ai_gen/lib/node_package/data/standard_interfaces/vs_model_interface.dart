import 'dart:async';

import 'package:ai_gen/core/classes/model_class.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.blue;

class VSModelInputData extends VSInputData {
  ///Basic List input interface
  VSModelInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [VSModelOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSModelOutputData extends VSOutputData<AIModel> {
  ///Basic List output interface
  VSModelOutputData({
    required super.type,
    FutureOr<AIModel> Function(Map<String, dynamic> data)? super.outputFunction,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
