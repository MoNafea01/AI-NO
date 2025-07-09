import 'package:ai_gen/core/data/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/features/node_view/data/node_builder/custom_interfaces/base/base_interface.dart';
import 'package:get_it/get_it.dart';

import 'base/universal_accepted_types.dart';

/// Shared state for managing multi-output node execution.
/// Tracks whether the node is currently running to prevent duplicate executions.
class OutputState {
  bool isRunning = false;
}

/// Input data interface for multi-output nodes.
/// Handles connections to various data types for multi-output processing.
class MultiOutputInputInterface extends BaseInputData {
  MultiOutputInputInterface({
    required super.node,
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
      ];
}

/// Output data interface for multi-output nodes.
/// Handles execution of nodes with multiple outputs and manages output state.
class MultiOutputOutputData extends BaseOutputData {
  MultiOutputOutputData({
    required this.index,
    required super.type,
    required super.node,
    required this.outputState,
    super.outputFunction,
  });

  /// The index of this output in the multi-output sequence.
  final int index;

  /// Shared state for managing execution across all outputs.
  final OutputState outputState;

  @override
  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get outputFunction {
    return (inputData) async {
      final nodeServices = GetIt.I.get<INodeServices>();

      // Only the first output triggers the actual node execution
      if (index == 0) {
        outputState.isRunning = true;
        await runNodeWithData(inputData);
        outputState.isRunning = false;
      } else {
        // Wait for node execution to complete before retrieving results
        int attempts = 0;
        while (node.nodeId == null) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
          if (attempts == 20 && !outputState.isRunning) {
            await runNodeWithData(inputData);
            break;
          }
        }
      }

      return await nodeServices.getNode(node, index + 1);
    };
  }
}
