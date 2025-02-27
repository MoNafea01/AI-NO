import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

const Color _interfaceColor = Colors.grey;

class VSDynamicInputData extends VSInputData {
  ///Basic dynamic input interface
  VSDynamicInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [];

  @override
  bool acceptInput(VSOutputData? data) {
    return true;
  }

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSDynamicOutputData extends VSOutputData<dynamic> {
  ///Basic dynamic output interface
  VSDynamicOutputData({
    required super.type,
    super.title,
    super.toolTip,
    super.outputFunction,
    super.interfaceIconBuilder,
  });

  @override
  Color get interfaceColor => _interfaceColor;
}
