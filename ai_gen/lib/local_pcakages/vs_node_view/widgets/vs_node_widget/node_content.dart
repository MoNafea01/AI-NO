import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_node_data.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_node_data_provider.dart';
import 'package:flutter/material.dart';

import 'vs_node_input.dart';
import 'vs_node_output.dart';
import 'vs_node_title.dart';

class NodeContent extends StatefulWidget {
  const NodeContent({
    required this.nodeProvider,
    required this.data,
    required this.anchor,
    super.key,
  });

  final VSNodeData data;
  final GlobalKey anchor;
  final VSNodeDataProvider nodeProvider;

  @override
  State<NodeContent> createState() => _NodeContentState();
}

class _NodeContentState extends State<NodeContent> {
  final List<GlobalKey<VSNodeOutputState>> _outputKeys = [];
  final List<Widget> inputWidgets = [];
  final List<Widget> outputWidgets = [];

  @override
  void initState() {
    for (final value in widget.data.inputData) {
      inputWidgets.add(VSNodeInput(data: value));
    }
    for (final value in widget.data.outputData) {
      final GlobalKey<VSNodeOutputState> key = GlobalKey<VSNodeOutputState>();
      _outputKeys.add(key);
      outputWidgets.add(VSNodeOutput(data: value, key: key));
    }
    super.initState();
  }

  void _updateOutputs() {
    for (final key in _outputKeys) {
      key.currentState?.updateRenderBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.anchor,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: _nodeDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          _InterfaceWidget(inputWidgets),
          VSNodeTitle(data: widget.data, onTitleChange: _updateOutputs),
          _InterfaceWidget(outputWidgets),
        ],
      ),
    );
  }

  BoxDecoration _nodeDecoration() {
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
      color: widget.nodeProvider.selectedNodes.contains(widget.data.id)
          ? Colors.lightBlue
          : widget.data.nodeColor,
    );
  }
}

class _InterfaceWidget extends StatelessWidget {
  const _InterfaceWidget(this.children);

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
