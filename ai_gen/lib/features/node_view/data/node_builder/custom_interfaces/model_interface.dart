import 'package:flutter/material.dart';

import 'custom_interfaces.dart';

/// Input data interface for model nodes.
/// Handles connections to model outputs and other compatible data types.
class VSModelInputData extends BaseInputData {
  ///Basic List input interface
  VSModelInputData({
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
        VSModelOutputData,
        VSNetworkOutputData,
        VSFitterOutputData,
      ];
}

/// Output data interface for model nodes.
/// Handles model execution and provides model-specific API communication.
class VSModelOutputData extends BaseOutputData {
  ///Basic List output interface
  VSModelOutputData({required super.type, required super.node});

  @override
  IconData get outputIcon => Icons.square_rounded;

  @override
  Map<String, dynamic> buildApiBody(Map<String, dynamic> inputData) {
    final Map<String, dynamic> apiBody = super.buildApiBody(inputData);

    // Add model-specific fields
    apiBody["model_name"] = node.name;
    apiBody["model_type"] = node.type;
    apiBody["task"] = node.task;

    return apiBody;
  }
}
