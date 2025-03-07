import 'package:flutter/material.dart';

import '../../../../../node_package/vs_node_view.dart';

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
