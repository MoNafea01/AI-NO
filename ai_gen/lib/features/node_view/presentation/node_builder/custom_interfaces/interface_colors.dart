import 'package:flutter/material.dart';

enum NodeTypes { general, models, preprocessors, core, custom, input, output }

extension NodesColorsExtension on NodeTypes {
  Color get color {
    switch (this) {
      case NodeTypes.models:
        return Colors.lightBlue;
      case NodeTypes.preprocessors:
        return Colors.yellow;
      case NodeTypes.core:
        return Colors.blue;
      case NodeTypes.custom:
        return Colors.grey;
      case NodeTypes.input:
        return Colors.orange;
      case NodeTypes.output:
        return Colors.lightBlue;
      default:
        return Colors.lightBlue;
    }
  }
}
