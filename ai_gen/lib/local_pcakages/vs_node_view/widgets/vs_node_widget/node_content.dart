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
  final List<Widget> inputWidgets = [];
  final List<Widget> outputWidgets = [];

  @override
  void initState() {
    for (final value in widget.data.inputData) {
      inputWidgets.add(VSNodeInput(data: value));
    }

    for (final value in widget.data.outputData) {
      outputWidgets.add(VSNodeOutput(data: value));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.anchor,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: _nodeDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _interfaceWidget(inputWidgets),
          const SizedBox(width: 8),
          VSNodeTitle(data: widget.data),
          const SizedBox(width: 8),
          _interfaceWidget(outputWidgets),
        ],
      ),
    );
  }

  Widget _interfaceWidget(List<Widget> widgets) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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
