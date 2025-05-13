import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_interface.dart';
import '../../data/vs_node_data_provider.dart';
import '../../special_nodes/vs_list_node.dart';
import '../line_drawer/gradiant_line_drawer.dart';

/// A widget that represents an output port for a node in the visual scripting interface.
///
/// This widget handles the visual representation and interaction of a node's output port,
/// including:
/// - Dragging to create connections to input ports
/// - Displaying the output port's icon and title
/// - Drawing connection lines during drag operations
/// - Providing tooltips for additional information
class VSNodeOutput extends StatefulWidget {
  /// Creates a new [VSNodeOutput] instance.
  ///
  /// [data] is required and contains the output port's data and state.
  const VSNodeOutput({required this.data, required this.outputKey, super.key});

  final Key outputKey;

  /// The data associated with this output port
  final VSOutputData data;

  @override
  State<VSNodeOutput> createState() => VSNodeOutputState();
}

/// The state for the [VSNodeOutput] widget.
///
/// This state class manages the output port's position, drag state, and rendering.
class VSNodeOutputState extends State<VSNodeOutput> {
  /// The current drag position for drawing the connection line
  Offset? _dragPosition;

  /// The render box for positioning calculations
  RenderBox? _renderBox;

  /// The key used to anchor the output port in the widget tree
  late final GlobalKey _anchor;

  @override
  void initState() {
    super.initState();
    _anchor = GlobalKey();
    _scheduleRenderBoxUpdate();
  }

  @override
  void didUpdateWidget(covariant VSNodeOutput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldUpdateRenderBox(oldWidget)) {
      _updateRenderBox();
    }
  }

  /// Determines if the render box should be updated
  bool _shouldUpdateRenderBox(VSNodeOutput oldWidget) {
    return widget.data.widgetOffset == null ||
        widget.data.widgetOffset != oldWidget.data.widgetOffset ||
        widget.data.title != oldWidget.data.title ||
        widget.data.nodeData is VSListNode;
  }

  /// Schedules an initial render box update
  void _scheduleRenderBoxUpdate() {
    Future.delayed(Duration.zero).then((_) {
      if (mounted) _updateRenderBox();
    });
  }

  /// Updates the render box for positioning calculations
  void _updateRenderBox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _renderBox = findAndUpdateWidgetPosition(
        widgetAnchor: _anchor,
        context: context,
        data: widget.data,
      );
    });
  }

  /// Updates the line position during drag operations
  void _updateLinePosition(Offset newPosition) {
    setState(() => _dragPosition = _renderBox?.globalToLocal(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        _buildOutputTitle(),
        _buildOutputIcon(context),
      ],
    );
  }

  /// Builds the output port's title
  Widget _buildOutputTitle() {
    return Text(
      widget.data.title,
      style: AppTextStyles.nodeInterfaceTextStyle,
    );
  }

  /// Builds the output port's icon with drag functionality
  CustomPaint _buildOutputIcon(BuildContext context) {
    return CustomPaint(
      key: widget.outputKey,
      foregroundPainter: _buildGradientLinePainter(),
      child: Draggable<VSOutputData>(
        data: widget.data,
        onDragUpdate: (details) => _updateLinePosition(details.localPosition),
        onDragEnd: (_) => setState(() => _dragPosition = null),
        onDraggableCanceled: (_, offset) => _handleDragCanceled(offset),
        feedback: _buildDragFeedback(),
        child: _buildOutputIconContent(context),
      ),
    );
  }

  /// Builds the icon shown during drag operations
  Widget _buildDragFeedback() {
    return Icon(
      widget.data.outputIcon,
      color: widget.data.interfaceColor,
      size: 15,
    );
  }

  /// Builds the main output icon content
  Widget _buildOutputIconContent(BuildContext context) {
    return wrapWithToolTip(
      toolTip: widget.data.toolTip,
      child: widget.data.getInterfaceIcon(
        context: context,
        anchor: _anchor,
      ),
    );
  }

  /// Handles drag cancellation by showing the context menu
  void _handleDragCanceled(Offset offset) {
    VSNodeDataProvider.of(context).openContextMenu(
      position: offset,
      outputData: widget.data,
    );
  }

  /// Builds the gradient line painter for the connection line
  GradientLinePainter _buildGradientLinePainter() {
    return GradientLinePainter(
      startPoint: getWidgetCenter(_renderBox),
      endPoint: _dragPosition,
      startColor: widget.data.interfaceColor,
      endColor: widget.data.interfaceColor,
    );
  }
}

/// A widget that represents a hidden output port for layout calculations.
///
/// This widget is used to maintain consistent spacing in the node layout
/// without showing the actual output port.
class HiddenVsNodeOutput extends StatelessWidget {
  /// Creates a new [HiddenVsNodeOutput] instance.
  ///
  /// [data] is required and contains the output port's data.
  const HiddenVsNodeOutput({required this.data, super.key});

  /// The data associated with this output port
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
