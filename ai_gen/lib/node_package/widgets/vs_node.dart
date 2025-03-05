import 'package:ai_gen/node_package/data/vs_node_data.dart';
import 'package:ai_gen/node_package/data/vs_node_data_provider.dart';
import 'package:ai_gen/node_package/widgets/vs_node_input.dart';
import 'package:ai_gen/node_package/widgets/vs_node_output.dart';
import 'package:ai_gen/node_package/widgets/vs_node_title.dart';
import 'package:flutter/material.dart';

class VSNode extends StatefulWidget {
  const VSNode({
    required this.data,
    this.width = 125,
    this.nodeTitleBuilder,
    super.key,
  });

  final VSNodeData data;
  final double width;
  final Widget Function(
    BuildContext context,
    VSNodeData nodeData,
  )? nodeTitleBuilder;

  @override
  State<VSNode> createState() => _VSNodeState();
}

class _VSNodeState extends State<VSNode> {
  final GlobalKey _anchor = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final List<Widget> interfaceWidgets = [];

    for (final value in widget.data.inputData) {
      interfaceWidgets.add(VSNodeInput(data: value));
    }

    for (final value in widget.data.outputData) {
      interfaceWidgets.add(VSNodeOutput(data: value));
    }

    final nodeProvider = VSNodeDataProvider.of(context);
    bool isSelected = nodeProvider.selectedNodes.contains(widget.data.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          // ✅ Ensure only one node is selected at a time
          nodeProvider.selectedNodes.clear();
          nodeProvider.selectedNodes.add(widget.data.id);
        });
      },
      child: Draggable(
        onDragEnd: (_) {
          final renderBox =
              _anchor.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            Offset position = renderBox.localToGlobal(Offset.zero);
            nodeProvider.moveNode(widget.data, position);
          }
        },
        feedback: Transform.scale(
          scale: 1 / nodeProvider.viewportScale,
          child: Card(
            key: _anchor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(widget.data.title),
                  SizedBox(width: widget.data.nodeWidth ?? widget.width),
                ],
              ),
            ),
          ),
        ),
        child: Card(
          color: isSelected
              ? Colors.blue
              : const Color(0xff349CFE), // ✅ Ensure blue selection
          elevation: isSelected ? 10 : 2, // ✅ Add elevation for selected node
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected
                ? const BorderSide(color: Colors.blue, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: widget.data.nodeWidth ?? widget.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.nodeTitleBuilder?.call(context, widget.data) ??
                      VSNodeTitle(data: widget.data),
                  ...interfaceWidgets,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
