import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_interface.dart';
import '../../data/vs_node_data_provider.dart';
import '../../special_nodes/vs_list_node.dart';

/// A widget that represents an input port for a node in the visual scripting interface.
///
/// This widget handles the visual representation and interaction of a node's input port,
/// including:
/// - Accepting connections from output ports
/// - Displaying the input port's icon and title
/// - Managing the connection state
/// - Providing tooltips for additional information
class VSNodeInput extends StatefulWidget {
  /// Creates a new [VSNodeInput] instance.
  ///
  /// [data] is required and contains the input port's data and state.
  const VSNodeInput({required this.data, super.key});

  /// The data associated with this input port
  final VSInputData data;

  @override
  State<VSNodeInput> createState() => _VSNodeInputState();
}

/// The state for the [VSNodeInput] widget.
///
/// This state class manages the input port's position, connection state, and rendering.
class _VSNodeInputState extends State<VSNodeInput> {
  /// The render box for positioning calculations
  RenderBox? _renderBox;

  /// The key used to anchor the input port in the widget tree
  final GlobalKey _anchor = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scheduleRenderBoxUpdate();
  }

  @override
  void didUpdateWidget(covariant VSNodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldUpdateRenderBox()) {
      _updateRenderBox();
    }
  }

  /// Determines if the render box should be updated
  bool _shouldUpdateRenderBox() {
    return widget.data.widgetOffset == null ||
        widget.data.nodeData is VSListNode;
  }

  /// Schedules an initial render box update
  void _scheduleRenderBoxUpdate() {
    Future.delayed(Duration.zero, _updateRenderBox);
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

  /// Updates the connected output port
  void _updateConnectedNode(VSOutputData? data) {
    widget.data.connectedInterface = data;

    VSNodeDataProvider.of(context).updateOrCreateNodes(
      [widget.data.nodeData!],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDragTarget(),
        _buildInputTitle(),
      ],
    );
  }

  /// Builds the drag target for accepting connections
  Widget _buildDragTarget() {
    return DragTarget<VSOutputData>(
      builder: _buildDragTargetContent,
      onWillAcceptWithDetails: _handleDragWillAccept,
      onAcceptWithDetails: _handleDragAccept,
    );
  }

  /// Builds the content of the drag target
  Widget _buildDragTargetContent(
    BuildContext context,
    List<dynamic> accepted,
    List<dynamic> rejected,
  ) {
    return GestureDetector(
      onTap: () => _updateConnectedNode(null),
      child: wrapWithToolTip(
        toolTip: widget.data.toolTip,
        child: widget.data.getInterfaceIcon(
          context: context,
          anchor: _anchor,
        ),
      ),
    );
  }

  /// Handles the drag will accept event
  bool _handleDragWillAccept(DragTargetDetails<VSOutputData> details) {
    return widget.data.acceptInput(details.data);
  }

  /// Handles the drag accept event
  void _handleDragAccept(DragTargetDetails<VSOutputData> details) {
    _updateConnectedNode(details.data);
  }

  /// Builds the input port's title
  Widget _buildInputTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        widget.data.title,
        style: AppTextStyles.nodeInterfaceTextStyle,
      ),
    );
  }
}

/// A widget that represents a hidden input port for layout calculations.
///
/// This widget is used to maintain consistent spacing in the node layout
/// without showing the actual input port.
class HiddenVSNodeInput extends StatelessWidget {
  /// Creates a new [HiddenVSNodeInput] instance.
  ///
  /// [data] is required and contains the input port's data.
  const HiddenVSNodeInput({required this.data, super.key});

  /// The data associated with this input port
  final VSInputData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        data.title,
        style: AppTextStyles.nodeInterfaceTextStyle
            .copyWith(color: Colors.transparent),
      ),
    );
  }
}
