import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:flutter/material.dart';

import 'base/base_interface.dart';
import 'base/universal_accepted_types.dart';
import 'model_interface.dart';
import 'multi_output_interface.dart';
import 'network_interface.dart';
import 'node_loader_interface.dart';
import 'preprocessor_interface.dart';

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
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
        BaseOutputData,
        VSModelOutputData,
        VSNetworkOutputData,
        VSFitterOutputData,
        VSNodeTemplateSaverOutputData,
        MultiOutputOutputData,
        VSPreprocessorInputData,
        VSNodeLoaderOutputData,
      ];
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
