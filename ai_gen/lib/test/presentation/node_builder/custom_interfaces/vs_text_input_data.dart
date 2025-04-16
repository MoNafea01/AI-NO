import 'package:flutter/material.dart';
<<<<<<<< HEAD:ai_gen/lib/test/presentation/node_builder/custom_interfaces/vs_text_input_data.dart
import 'package:vs_node_view/data/standard_interfaces/vs_int_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_num_interface.dart';
import 'package:vs_node_view/data/vs_interface.dart';
========

import '../../../../../node_package/vs_node_view.dart';
>>>>>>>> main:ai_gen/lib/features/node_view/presentation/node_builder/custom_interfaces/vs_text_input_data.dart

class VsTextInputData extends VSInputData {
  ///Basic int input interface
  VsTextInputData({
    required super.type,
    super.toolTip,
    super.interfaceIconBuilder,
    required this.controller,
    super.initialConnection,
  }) {
    super.interfaceIconBuilder = (context, anchor, data) {
      return SizedBox(
        key: anchor,
        width: 120,
        height: 50,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: type),
        ),
      );
    };
    super.title = "";
  }
  final TextEditingController controller;
  @override
  List<Type> get acceptedTypes => [VSIntOutputData, VSNumOutputData];

  final Color _interfaceColor = Colors.yellow;
  @override
  Color get interfaceColor => _interfaceColor;
}
