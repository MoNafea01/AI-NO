import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_node_data.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_node_data_provider.dart';
import 'package:flutter/material.dart';

import 'vs_node_input.dart';
import 'vs_node_output.dart';
import 'vs_node_title.dart';

/// A widget that represents the content of a node in the visual scripting interface.
///
/// This widget handles the visual representation of a node's content, including:
/// - Node title
/// - Input and output ports
/// - Node styling and selection state
/// - Connection points for node links
class NodeContent extends StatefulWidget {
  /// Creates a new [NodeContent] instance.
  ///
  /// [nodeProvider] is required and manages the node data and state.
  /// [data] is required and contains the node's data.
  /// [anchor] is required and provides a reference point for the node.
  const NodeContent({
    required this.nodeProvider,
    required this.data,
    required this.anchor,
    super.key,
  });

  /// The data associated with this node
  final VSNodeData data;

  /// The key used to anchor the node in the widget tree
  final GlobalKey anchor;

  /// The provider that manages node data and state
  final VSNodeDataProvider nodeProvider;

  @override
  State<NodeContent> createState() => NodeContentState();
}

/// The state for the [NodeContent] widget.
///
/// This state class manages the node's content layout, ports, and rendering.
class NodeContentState extends State<NodeContent> {
  /// Keys for tracking output port positions
  final List<GlobalKey<VSNodeOutputState>> _outputKeys = [];

  /// Widgets for visible input ports
  final List<Widget> _inputWidgets = [];

  /// Widgets for hidden input ports
  final List<Widget> _hiddenInputWidgets = [];

  /// Widgets for visible output ports
  final List<Widget> _outputWidgets = [];

  /// Widgets for hidden output ports
  final List<Widget> _hiddenOutputWidgets = [];

  @override
  void initState() {
    super.initState();
    _initializePorts();
  }

  /// Initializes the input and output ports
  void _initializePorts() {
    // Initialize input ports
    for (final inputData in widget.data.inputData) {
      _inputWidgets.add(VSNodeInput(data: inputData));
      _hiddenInputWidgets.add(HiddenVSNodeInput(data: inputData));
    }

    // Initialize output ports
    for (final outputData in widget.data.outputData) {
      final GlobalKey<VSNodeOutputState> key = GlobalKey<VSNodeOutputState>();
      _outputKeys.add(key);
      _outputWidgets.add(VSNodeOutput(data: outputData, outputKey: key));
      _hiddenOutputWidgets.add(HiddenVsNodeOutput(data: outputData));
    }
  }

  /// Updates the render boxes for all output ports
  void updateOutputs() {
    for (final key in _outputKeys) {
      if (key.currentState != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            key.currentState?.setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: widget.anchor,
      children: [
        _buildMainContent(),
        _buildInputPorts(),
        _buildOutputPorts(),
      ],
    );
  }

  /// Builds the main content of the node
  Widget _buildMainContent() {
    return Row(
      children: [
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: _buildNodeDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              _InterfaceWidget(_hiddenInputWidgets),
              VSNodeTitle(data: widget.data, onTitleChange: updateOutputs),
              _InterfaceWidget(_hiddenOutputWidgets),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the input ports positioned on the left side
  Widget _buildInputPorts() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: _InterfaceWidget(_inputWidgets),
    );
  }

  /// Builds the output ports positioned on the right side
  Widget _buildOutputPorts() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: _InterfaceWidget(_outputWidgets),
    );
  }

  /// Builds the decoration for the node container
  BoxDecoration _buildNodeDecoration() {
    final bool isSelected =
        widget.nodeProvider.selectedNodes.contains(widget.data.id);

    return BoxDecoration(
      border: Border.all(color: Colors.black38),
      boxShadow: const [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
      borderRadius: BorderRadius.circular(12),
      color: isSelected ? Colors.lightBlue : widget.data.nodeColor,
    );
  }
}

/// A widget that displays a list of interface elements in a column.
///
/// This widget is used to organize input and output ports in a vertical layout.
class _InterfaceWidget extends StatelessWidget {
  /// Creates a new [_InterfaceWidget] instance.
  ///
  /// [children] is required and contains the list of widgets to display.
  const _InterfaceWidget(this.children);

  /// The list of widgets to display in the interface
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
