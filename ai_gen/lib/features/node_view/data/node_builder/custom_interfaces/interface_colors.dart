import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// Enumeration of different node types used for color coding.
/// Each node type has a specific color to help users identify node categories visually.
enum NodeTypes {
  /// General purpose nodes
  general,

  /// Machine learning model nodes
  models,

  /// Data preprocessing nodes
  preprocessors,

  /// Core system nodes
  core,

  /// Custom user-defined nodes
  custom,

  /// Input data nodes
  input,

  /// Output/result nodes
  output,

  /// Neural network nodes
  network,
}

/// Extension providing color mapping for node types.
/// Each node type is assigned a specific color for visual identification.
extension NodesColorsExtension on NodeTypes {
  /// Returns the color associated with this node type.
  Color get color {
    switch (this) {
      case NodeTypes.models:
        return const Color(0xFF3E8E40); // Green for models
      case NodeTypes.preprocessors:
        return const Color(0xFFCC9900); // Orange for preprocessors
      case NodeTypes.core:
        return const Color(0xFF666666); // Gray for core nodes
      case NodeTypes.custom:
        return const Color(0xFF666666); // Gray for custom nodes
      case NodeTypes.input:
        return Colors.orange.shade700; // Dark orange for input
      case NodeTypes.output:
        return Colors.lightBlue; // Light blue for output
      case NodeTypes.network:
        return Colors.brown; // Brown for network nodes
      case NodeTypes.general:
        return AppColors.bluePrimaryColor; // Default light blue
    }
  }
}
