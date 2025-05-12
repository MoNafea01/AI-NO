import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_interface.dart';
import '../../data/vs_node_data_provider.dart';
import '../../special_nodes/vs_list_node.dart';
import '../line_drawer/gradiant_line_drawer.dart';

class VSNodeOutput extends StatefulWidget {
  const VSNodeOutput({required this.data, Key? key}) : super(key: key);

  final VSOutputData data;

  @override
  State<VSNodeOutput> createState() => VSNodeOutputState();
}

class VSNodeOutputState extends State<VSNodeOutput> {
  Offset? dragPos;
  RenderBox? renderBox;
  late final GlobalKey _anchor;

  @override
  void initState() {
    _anchor = GlobalKey();
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      if (mounted) updateRenderBox();
    });
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
      if (!mounted) return;
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        outputTitle(),
        outputIcon(context),
      ],
    );
  }

  Widget outputTitle() {
    return Text(
      widget.data.title,
      style: AppTextStyles.nodeInterfaceTextStyle,
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

class HiddenVsNodeOutput extends StatelessWidget {
  const HiddenVsNodeOutput({required this.data, super.key});

  final VSOutputData data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data.title,
      style: AppTextStyles.nodeInterfaceTextStyle
          .copyWith(color: Colors.transparent),
    );
  }
}
