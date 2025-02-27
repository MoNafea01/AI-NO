import 'package:ai_gen/node_package/data/evaluation_error.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:ai_gen/node_package/data/vs_node_data.dart';
import 'package:ai_gen/node_package/special_nodes/vs_list_node.dart';

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
  MapEntry<String, dynamic> evaluate({
    Function(Object e, StackTrace s)? onError,
  }) {
    try {
      Map<String, Map<String, dynamic>> nodeInputValues = {};
      _traverseInputNodes(nodeInputValues, this);

      return MapEntry(title, nodeInputValues[id]!.values.first);
    } catch (e, s) {
      onError?.call(e, s);
    }
    return MapEntry(title, null);
  }

  ///Traverses input nodes
  ///
  ///Used by evalTree to recursivly move through the nodes
  void _traverseInputNodes(
    Map<String, Map<String, dynamic>> nodeInputValues,
    VSNodeData data,
  ) {
    Map<String, dynamic> inputValues = {};

    final inputs = data is VSListNode ? data.getCleanInputs() : data.inputData;

    for (final input in inputs) {
      final connectedNode = input.connectedInterface;
      if (connectedNode != null) {
        if (!nodeInputValues.containsKey(connectedNode.nodeData!.id)) {
          _traverseInputNodes(
            nodeInputValues,
            connectedNode.nodeData!,
          );
        }

        try {
          inputValues[input.type] = connectedNode.outputFunction?.call(
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
