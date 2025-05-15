import 'package:ai_gen/local_pcakages/vs_node_view/data/standard_interfaces/vs_int_interface.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/standard_interfaces/vs_num_interface.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';

class VsTextInputData extends VSInputData {
  ///Basic int input interface
  VsTextInputData({
    required super.type,
    required this.controller,
    super.interfaceIconBuilder,
    super.title = "xx",
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
  }
  final TextEditingController controller;
  @override
  List<Type> get acceptedTypes => [VSIntOutputData, VSNumOutputData];

  final Color _interfaceColor = Colors.yellow;
  @override
  Color get interfaceColor => _interfaceColor;
}
