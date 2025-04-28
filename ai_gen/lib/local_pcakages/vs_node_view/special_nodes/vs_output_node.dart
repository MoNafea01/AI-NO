import '../data/evaluation_error.dart';
import '../data/standard_interfaces/vs_dynamic_interface.dart';
import '../data/vs_interface.dart';
import '../data/vs_node_data.dart';
import 'vs_list_node.dart';

class VSOutputNode extends VSNodeData {
  ///Output Node
  ///
  ///Used to traverse the node tree and evalutate them to a result
  VSOutputNode({
    required super.type,
    required super.widgetOffset,
    VSOutputData? ref,
    super.nodeWidth,
    super.title,
    super.toolTip,
    String? inputTitle,
    super.node,
    super.onUpdatedConnection,
  }) : super(
          inputData: [
            VSDynamicInputData(
              type: type,
              title: inputTitle,
              initialConnection: ref,
            )
          ],
          outputData: const [],
        );

  ///Evalutes the tree from this node and returns the result
  ///
  ///Supply an onError function to be called when an error occures inside the evaluation
  Future<MapEntry<String, dynamic>> evaluate({
    Function(Object e, StackTrace s)? onError,
  }) async {
    try {
      Map<String, Map<String, dynamic>> nodeInputValues = {};
      await _traverseInputNodes(nodeInputValues, this);

      return MapEntry(title, nodeInputValues[id]!.values.first);
    } catch (e, s) {
      onError?.call(e, s);
    }
    return MapEntry(title, null);
  }

  ///Traverses input nodes
  ///
  ///Used by evalTree to recursivly move through the nodes
  Future<void> _traverseInputNodes(
    Map<String, Map<String, dynamic>> nodeInputValues,
    VSNodeData data,
  ) async {
    Map<String, dynamic> inputValues = {};

    final inputs = data is VSListNode ? data.getCleanInputs() : data.inputData;

    for (final input in inputs) {
      final connectedNode = input.connectedInterface;
      if (connectedNode != null) {
        if (!nodeInputValues.containsKey(connectedNode.nodeData!.id)) {
          await _traverseInputNodes(
            nodeInputValues,
            connectedNode.nodeData!,
          );
        }

        try {
          inputValues[input.type] = await connectedNode.outputFunction?.call(
            nodeInputValues[connectedNode.nodeData!.id]!,
          );
        } catch (e) {
          throw EvalutationError(
            nodeData: connectedNode.nodeData!,
            inputData: nodeInputValues[connectedNode.nodeData!.id]!,
            error: e,
          );
        }
      } else {
        inputValues[input.type] = null;
      }
    }
    nodeInputValues[data.id] = inputValues;
  }
}
