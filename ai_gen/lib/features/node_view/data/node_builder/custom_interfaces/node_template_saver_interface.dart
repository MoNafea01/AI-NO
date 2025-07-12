import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';

import 'base/base_interface.dart';

/// Input data interface for node template saver nodes.
/// Handles connections to various node types for template saving operations.
class VSNodeTemplateSaverInputData extends BaseInputData {
  ///Basic List input interface
  VSNodeTemplateSaverInputData({
    required super.type,
    required super.node,
    super.title,
    super.toolTip,
    super.initialConnection,
  });

  @override
  IconData get connectedInputIcon => Icons.square_rounded;
  @override
  IconData get inputIcon => Icons.square_outlined;

  @override
  bool acceptInput(VSOutputData? data) => true;

  @override
  List<Type> get acceptedTypes => [];
}

/// Output data interface for node template saver nodes.
/// Handles template saving operations and provides saver-specific functionality.
class VSNodeTemplateSaverOutputData extends BaseOutputData {
  ///Basic List output interface
  VSNodeTemplateSaverOutputData({required super.type, required super.node});

  @override
  IconData get outputIcon => Icons.square_rounded;

  @override
  Future<void> Function(Map<String, dynamic> data) get outputFunction {
    return (Map<String, dynamic> data) async {
      await runNodeWithData(data);
    };
  }
}
