import 'package:ai_gen/node_package/common.dart';
import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:ai_gen/node_package/data/vs_node_data_provider.dart';
import 'package:ai_gen/node_package/special_nodes/vs_list_node.dart';
import 'package:ai_gen/node_package/special_nodes/vs_widget_node.dart';
import 'package:ai_gen/node_package/widgets/line_drawer/gradiant_line_drawer.dart';
import 'package:flutter/material.dart';

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
    final Widget firstItem = widget.data.nodeData is VSWidgetNode &&
            (widget.data.nodeData as VSWidgetNode).child != null
        ? (widget.data.nodeData as VSWidgetNode).child!
        : Expanded(child: Text(widget.data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black),
          ),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        firstItem,
        CustomPaint(
          foregroundPainter: GradientLinePainter(
            startPoint: getWidgetCenter(renderBox),
            endPoint: dragPos,
            startColor: widget.data.interfaceColor,
            endColor: widget.data.interfaceColor,  //widget.data.interfaceColor  
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

            feedback:  Icon(
              Icons.circle, //-----------------  Icons.circle  مقدمه الخط بتاع التوصيل 
              color: widget.data.interfaceColor, // widget.data.interfaceColor  لون راس الايقون
              size: 13,
              
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
