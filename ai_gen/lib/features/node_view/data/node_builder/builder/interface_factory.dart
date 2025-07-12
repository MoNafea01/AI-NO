import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';

import '../custom_interfaces/custom_interfaces.dart';

/// Factory class for creating input and output data interfaces.
/// Provides a centralized way to instantiate the appropriate interface
/// based on node properties and connection types.
class InterfaceFactory {
  /// Creates an input data interface based on the input type and node.
  static VSInputData createInputData(
    NodeModel node,
    String inputType,
    VSOutputData? initialConnection,
  ) {
    switch (inputType) {
      case "model":
      case "fitted_model":
        return VSModelInputData(
          type: inputType,
          node: node,
          initialConnection: initialConnection,
        );
      case "preprocessor":
      case "fitted_preprocessor":
        return VSPreprocessorInputData(
          type: inputType,
          node: node,
          initialConnection: initialConnection,
        );
      case "node":
        return VSAINOGeneralInputData(
          type: inputType,
          node: node,
          initialConnection: initialConnection,
          acceptAll: true,
        );
      default:
        // Special cases for specific node types
        if (node.name == "node_template_saver") {
          return VSNodeTemplateSaverInputData(
            type: inputType,
            node: node,
            initialConnection: initialConnection,
          );
        }

        // Default to general interface
        return VSAINOGeneralInputData(
          type: inputType,
          node: node,
          initialConnection: initialConnection,
        );
    }
  }

  /// Creates output data interfaces based on the node category and properties.
  static List<VSOutputData> createOutputData(NodeModel node) {
    if (node.outputDots == null || node.outputDots!.isEmpty) {
      return [];
    }

    // Handle multi-output nodes
    if (node.outputDots!.length > 1) {
      return _createMultiOutputData(node);
    }

    final String outputType = node.outputDots![0];

    // Create single output based on node category
    switch (node.category) {
      case "Models":
        return [VSModelOutputData(type: outputType, node: node)];
      case "Preprocessors":
        return [VSPreprocessorOutputData(type: outputType, node: node)];
      case "Network":
        return [VSNetworkOutputData(type: outputType, node: node)];
    }

    // Handle special node types
    switch (node.name) {
      case "model_fitter":
      case "preprocessor_fitter":
        return [
          VSFitterOutputData(
            type: outputType,
            node: node,
            outputIcon: Icons.square_sharp,
          )
        ];
      case "node_template_saver":
        return [VSNodeTemplateSaverOutputData(type: outputType, node: node)];
      case "node_loader":
        return [VSNodeLoaderOutputData(type: outputType, node: node)];
    }

    // template nodes created by the user
    if (node.task == "template") {
      return [VSNodeTemplateSaverOutputData(type: outputType, node: node)];
    }

    // Default to general interface
    return [VSAINOGeneralOutputData(type: outputType, node: node)];
  }

  /// Creates multi-output data interfaces for nodes with multiple outputs.
  static List<MultiOutputOutputData> _createMultiOutputData(NodeModel node) {
    final List<MultiOutputOutputData> outputData = [];
    final outputState = OutputState();

    for (int i = 0; i < node.outputDots!.length; i++) {
      outputData.add(
        MultiOutputOutputData(
          index: i,
          node: node,
          type: node.outputDots![i],
          outputState: outputState,
        ),
      );
    }
    return outputData;
  }
}
