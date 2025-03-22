import 'package:flutter/material.dart';

enum NodeTypes { general, models, preprocessors, core, custom, input, output }

extension NodesColorsExtension on NodeTypes {
  Color get color {
    switch (this) {
      case NodeTypes.models:
        return const Color(0xFF3E8E40);
      case NodeTypes.preprocessors:
        return const Color(0xFFCC9900);
      case NodeTypes.core:
        return Colors.brown;
      case NodeTypes.custom:
        return const Color(0xFF666666);
      case NodeTypes.input:
        return Colors.orange.shade700;
      case NodeTypes.output:
        return Colors.lightBlue;
      default:
        return Colors.lightBlue;
    }
  }
}
