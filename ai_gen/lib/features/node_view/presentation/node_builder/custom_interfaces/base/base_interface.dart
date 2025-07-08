import 'package:ai_gen/core/data/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Base class for all output data interfaces.
/// Provides common functionality for node execution and API communication.
abstract class BaseOutputData extends VSOutputData {
  BaseOutputData({
    required super.type,
    required this.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });

  /// The node model associated with this output data.
  final NodeModel node;

  @override
  Color get interfaceColor => node.color;

  /// Builds the API request body for node execution.
  /// Override this method to customize the request structure.
  Map<String, dynamic> buildApiBody(Map<String, dynamic> inputData) {
    final Map<String, dynamic> apiBody = {};
    apiBody["params"] = node.paramsToJson;

    // Add input data to the request
    for (var input in inputData.entries) {
      apiBody[input.key] = input.value;
    }

    return apiBody;
  }

  /// Executes the node with the provided input data.
  /// This is the main method for running node operations.
  Future<Map<String, dynamic>> runNodeWithData(
    Map<String, dynamic> data,
  ) async {
    try {
      final Map<String, dynamic> apiBody = buildApiBody(data);
      final nodeServices = GetIt.I.get<INodeServices>();
      final response = await nodeServices.runNode(node, apiBody);

      if (response['node_data'] is String) {
        node.userOutput = response['message'];
      } else {
        node.userOutput = response['node_data'];
      }

      return response;
    } catch (e) {
      // Log error and rethrow for proper error handling
      debugPrint('Error running node ${node.name}: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      runNodeWithData;
}

/// Base class for all input data interfaces.
/// Provides common functionality for input validation and connection handling.
abstract class BaseInputData extends VSInputData {
  BaseInputData({
    required super.type,
    required this.node,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  /// The node model associated with this input data.
  NodeModel? node;

  @override
  Color get interfaceColor => node?.color ?? NodeTypes.general.color;

  /// Validates if the provided output data can be connected to this input.
  /// Override this method to add custom validation logic.
  @override
  bool acceptInput(VSOutputData? data) {
    if (data == null) return false;
    return acceptedTypes.contains(data.runtimeType);
  }
}
