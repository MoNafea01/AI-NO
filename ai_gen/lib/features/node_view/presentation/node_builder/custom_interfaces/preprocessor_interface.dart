import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:flutter/material.dart';

import 'base/base_interface.dart';
import 'base/universal_accepted_types.dart';
import 'network_interface.dart';
import 'node_loader_interface.dart';

/// Input data interface for preprocessor nodes.
/// Handles connections to preprocessor outputs and other compatible data types.
class VSPreprocessorInputData extends BaseInputData {
  ///Basic List input interface
  VSPreprocessorInputData({
    required super.type,
    required super.node,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.connectedInputIcon,
  });

  @override
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
        VSPreprocessorOutputData,
        VSFitterOutputData,
        VSNetworkOutputData,
        VSNodeLoaderOutputData
      ];

  @override
  // implement inputIcon
  IconData get inputIcon => Icons.square_outlined;

  @override
  IconData get connectedInputIcon => Icons.square_rounded;
}

/// Output data interface for preprocessor nodes.
/// Handles preprocessor execution and provides preprocessor-specific API communication.
class VSPreprocessorOutputData extends BaseOutputData {
  ///Basic List output interface
  VSPreprocessorOutputData({
    required super.type,
    required super.node,
  });

  @override
  IconData get outputIcon => Icons.square_sharp;

  @override
  Map<String, dynamic> buildApiBody(Map<String, dynamic> inputData) {
    final Map<String, dynamic> apiBody = super.buildApiBody(inputData);

    // Add preprocessor-specific fields
    apiBody["preprocessor_name"] = node.name;
    apiBody["preprocessor_type"] = node.type;

    return apiBody;
  }

  @override
  Color get interfaceColor => node.color;
}
