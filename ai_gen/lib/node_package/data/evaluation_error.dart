import 'package:ai_gen/node_package/vs_node_view.dart';

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
