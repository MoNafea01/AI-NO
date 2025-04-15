import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_interface.dart';
import '../../data/vs_node_data_provider.dart';
import '../../special_nodes/vs_list_node.dart';
import '../../special_nodes/vs_widget_node.dart';
import '../line_drawer/gradiant_line_drawer.dart';

class VSNodeOutput extends StatefulWidget {
  const VSNodeOutput({required this.data, super.key});

  final VSOutputData data;

  @override
  State<VSNodeOutput> createState() => _VSNodeOutputState();
}

class _VSNodeOutputState extends State<VSNodeOutput> {
  Offset? dragPos;
  RenderBox? renderBox;
  late final GlobalKey _anchor;

  @override
  void initState() {
    _anchor = GlobalKey();
    super.initState();
    updateRenderBox();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateRenderBox();
  }

  @override
  void didUpdateWidget(covariant VSNodeOutput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data.widgetOffset == null ||
        widget.data.widgetOffset != oldWidget.data.widgetOffset ||
        widget.data.title != oldWidget.data.title ||
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
    final outputTitle = widget.data.nodeData is VSWidgetNode
        ? (widget.data.nodeData as VSWidgetNode).child
        : Text(
            widget.data.title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        outputTitle,
        const SizedBox(width: 3),
        outputIcon(context),
      ],
    );
  }

  CustomPaint outputIcon(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _buildGradientLinePainter(),
      child: Draggable<VSOutputData>(
        data: widget.data,
        onDragUpdate: (details) => updateLinePosition(details.localPosition),
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
    );
  }

  GradientLinePainter _buildGradientLinePainter() {
    return GradientLinePainter(
      startPoint: getWidgetCenter(renderBox),
      endPoint: dragPos,
      startColor: widget.data.interfaceColor,
      endColor: widget.data.interfaceColor,
    );
  }
}
