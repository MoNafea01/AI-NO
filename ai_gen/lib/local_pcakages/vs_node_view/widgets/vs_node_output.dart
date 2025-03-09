import 'package:flutter/material.dart';

import '../common.dart';
import '../data/vs_interface.dart';
import '../data/vs_node_data_provider.dart';
import '../special_nodes/vs_list_node.dart';
import '../special_nodes/vs_widget_node.dart';
import 'line_drawer/gradiant_line_drawer.dart';

class VSNodeOutput extends StatefulWidget {
  ///Base node output widget
  ///
  ///Used in [VSNode]
  ///
  ///Uses [Draggable] to make a connection with [VSInputData]
  const VSNodeOutput({
    required this.data,
    super.key,
  });

  final VSOutputData data;

  @override
  State<VSNodeOutput> createState() => _VSNodeOutputState();
}

class _VSNodeOutputState extends State<VSNodeOutput> {
  Offset? dragPos;
  RenderBox? renderBox;
  final GlobalKey _anchor = GlobalKey();

  @override
  void initState() {
    super.initState();

    updateRenderBox();
  }

  @override
  void didUpdateWidget(covariant VSNodeOutput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data.widgetOffset == null ||
        widget.data.nodeData is VSListNode) {
      updateRenderBox();
    }
  }

  void updateRenderBox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      renderBox = findAndUpdateWidgetPosition(
        widgetAnchor: _anchor,
        context: context,
        data: widget.data,
      );
    });
  }

  void updateLinePosition(Offset newPosition) {
    setState(() => dragPos = renderBox?.globalToLocal(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.data.nodeData is VSWidgetNode
        ? (widget.data.nodeData as VSWidgetNode).child
        : Text(widget.data.title);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          // ensure a space between the text and the output icon
          padding: const EdgeInsets.only(right: 24),
          child: firstItem,
        ),
        CustomPaint(
          foregroundPainter: GradientLinePainter(
            startPoint: getWidgetCenter(renderBox),
            endPoint: dragPos,
            startColor: widget.data.interfaceColor,
            endColor: widget.data.interfaceColor,
          ),
          child: Draggable<VSOutputData>(
            data: widget.data,
            onDragUpdate: (details) =>
                updateLinePosition(details.localPosition),
            onDragEnd: (details) => setState(() {
              dragPos = null;
            }),
            onDraggableCanceled: (velocity, offset) {
              VSNodeDataProvider.of(context).openContextMenu(
                position: offset,
                outputData: widget.data,
              );
            },
            feedback: Icon(
              widget.data.outputIcon,
              color: widget.data.interfaceColor,
              size: 15,
            ),
            child: wrapWithToolTip(
              toolTip: widget.data.toolTip,
              child: widget.data.getInterfaceIcon(
                context: context,
                anchor: _anchor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
