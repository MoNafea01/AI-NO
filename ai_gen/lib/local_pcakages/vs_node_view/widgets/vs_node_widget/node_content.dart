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
  final List<Widget> hiddenInputWidgets = [];
  final List<Widget> outputWidgets = [];
  final List<Widget> hiddenOutputWidgets = [];

  @override
  void initState() {
    for (final value in widget.data.inputData) {
      inputWidgets.add(VSNodeInput(data: value));
      hiddenInputWidgets.add(HiddenVSNodeInput(data: value));
    }

    for (final value in widget.data.outputData) {
      final GlobalKey<VSNodeOutputState> key = GlobalKey<VSNodeOutputState>();
      _outputKeys.add(key);
      outputWidgets.add(VSNodeOutput(data: value, key: key));
      hiddenOutputWidgets.add(HiddenVsNodeOutput(data: value));
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
    return Stack(
      key: widget.anchor,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: _nodeDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  _InterfaceWidget(hiddenInputWidgets),
                  VSNodeTitle(data: widget.data, onTitleChange: _updateOutputs),
                  _InterfaceWidget(hiddenOutputWidgets),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: _InterfaceWidget(inputWidgets),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: _InterfaceWidget(outputWidgets),
        ),
      ],
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
