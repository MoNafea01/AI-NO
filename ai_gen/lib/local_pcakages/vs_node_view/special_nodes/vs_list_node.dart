import '../data/vs_interface.dart';
import '../data/vs_node_data.dart';

/// A specialized node that bundles multiple inputs into a single output.
///
/// This node type is useful for combining multiple input values into a single
/// output value. It dynamically manages its input ports based on connections.
class VSListNode extends VSNodeData {
  /// Creates a new [VSListNode] instance.
  ///
  /// [id] is an optional unique identifier for the node.
  /// [type] is required and specifies the type of the node.
  /// [widgetOffset] is required and determines the node's position.
  /// [inputBuilder] is required and used to build input interfaces.
  /// [outputData] is required and contains the node's output interfaces.
  /// [nodeWidth] is optional and specifies the node's width.
  /// [title] is optional and sets the node's display title.
  /// [toolTip] is optional and provides additional information.
  /// [onUpdatedConnection] is optional and called when connections change.
  /// [referenceConnection] is optional and sets the initial connection.
  VSListNode({
    super.id,
    required super.type,
    required super.widgetOffset,
    required this.inputBuilder,
    required Iterable<VSOutputData> super.outputData,
    super.nodeWidth,
    super.title,
    super.toolTip,
    Function(VSInputData interfaceData)? super.onUpdatedConnection,
    VSOutputData? referenceConnection,
  }) : super(
          inputData: [
            inputBuilder(0, null)..connectedInterface = referenceConnection,
          ],
        ) {
    if (inputData.first.connectedInterface != null) {
      _setInputs([inputData.first.connectedInterface]);
    }
  }

  /// Used to build the node's inputs dynamically.
  ///
  /// [index] is the current index of this input in the [inputData] of this node.
  /// [connection] is the initial connection for this input.
  final VSInputData Function(int index, VSOutputData? connection) inputBuilder;

  @override
  Function(VSInputData interfaceData)? get onUpdatedConnection => _updateInputs;

  /// Gets the inputs of this [VSListNode] that have connected interfaces.
  ///
  /// Returns a list of [VSInputData] that have non-null [connectedInterface].
  List<VSInputData> getCleanInputs() {
    return inputData
        .where(
          (element) => element.connectedInterface != null,
        )
        .toList();
  }

  /// Updates the input list when a connection changes.
  void _updateInputs(VSInputData interfaceData) {
    final cleanInputData = getCleanInputs();
    _setInputs(cleanInputData.map((e) => e.connectedInterface));

    super.onUpdatedConnection?.call(interfaceData);
  }

  /// Sets the input list based on the provided connections.
  void _setInputs(Iterable<VSOutputData?> connectedInterface) {
    final List<VSInputData> newInputData = [];
    final interfaces = [...connectedInterface, null];

    for (int i = 0; i < interfaces.length; i++) {
      final currentInput = inputBuilder(
        i,
        interfaces.elementAtOrNull(i),
      );
      currentInput.nodeData = this;
      newInputData.add(currentInput);
    }

    // Update the input data list
    inputData = newInputData;
  }

  /// Used for deserializing node data.
  ///
  /// Reconstructs list connections based on the provided input references.
  @override
  void setRefData(Map<String, VSOutputData?> inputRefs) {
    _setInputs(inputRefs.values);
  }
}
