import 'vs_node_data.dart';

class EvalutationError {
  EvalutationError({
    required this.nodeData,
    required this.inputData,
    required this.error,
  });

  final VSNodeData nodeData;
  final Map<String, dynamic> inputData;

  final Object error;
}
