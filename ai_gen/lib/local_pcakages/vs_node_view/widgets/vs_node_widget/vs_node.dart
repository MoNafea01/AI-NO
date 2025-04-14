import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/vs_node_data.dart';
import '../../data/vs_node_data_provider.dart';
import 'vs_node_input.dart';
import 'vs_node_output.dart';
import 'vs_node_title.dart';

class VSNode extends StatefulWidget {
  /// The base node widget
  /// Used inside [VSNodeView] to display nodes
  const VSNode({
    required this.data,
    this.width = 125,
    this.nodeTitleBuilder,
    super.key,
  });

  /// The data the widget will use to build the UI
  final VSNodeData data;

  /// Default width of the node
  /// Will be used unless width is specified inside [VSNodeData]
  final double width;

  /// Can be used to take control over the building of the node titles
  /// See [VSNodeTitle] for reference
  final Widget Function(
    BuildContext context,
    VSNodeData nodeData,
  )? nodeTitleBuilder;

  @override
  State<VSNode> createState() => _VSNodeState();
}

class _VSNodeState extends State<VSNode> {
  final GlobalKey _anchor = GlobalKey();
  final GlobalKey key2 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final nodeProvider = VSNodeDataProvider.of(context);

    return Draggable(
      onDragEnd: (details) {
        if (_anchor.currentContext == null) return;
        final RenderBox renderBox =
            _anchor.currentContext?.findRenderObject() as RenderBox;
        Offset newPosition = renderBox.localToGlobal(Offset.zero);

        // Update the node position if it has changed
        nodeProvider.moveNode(widget.data, newPosition);
      },
      feedback: draggedNode(nodeProvider, context),
      childWhenDragging: const SizedBox(),
      child: _node(context, nodeProvider),
    );
  }

  Transform draggedNode(VSNodeDataProvider nodeProvider, BuildContext context) {
    return Transform.scale(
      scale: 1 / nodeProvider.viewportScale,
      child: Material(
        key: key2,
        borderRadius: BorderRadius.circular(12),
        child: _buildNodeContent(context),
      ),
    );
  }

  GestureDetector _node(BuildContext context, VSNodeDataProvider nodeProvider) {
    return GestureDetector(
      onDoubleTap: () {
        context
            .read<GridNodeViewCubit>()
            .updateActiveNodePropertiesCard(widget.data.node);
      },
      onSecondaryTapUp: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          items: const [
            PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ).then((value) {
          if (value == 'rename') {
            setState(() => widget.data.isRenaming = true);
          } else if (value == 'delete') {
            setState(() {
              widget.data.deleteNode?.call();
              nodeProvider.removeNodes([widget.data]);
            });
          }
        });
      },
      child: _buildNodeContent(context),
    );
  }

  Widget _buildNodeContent(BuildContext context) {
    final VSNodeDataProvider nodeProvider = VSNodeDataProvider.of(context);
    final List<Widget> inputWidgets = [];
    final List<Widget> outputWidgets = [];

    for (final value in widget.data.inputData) {
      inputWidgets.add(VSNodeInput(data: value));
    }

    for (final value in widget.data.outputData) {
      outputWidgets.add(VSNodeOutput(data: value));
    }
    return Container(
      key: _anchor,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        color: nodeProvider.selectedNodes.contains(widget.data.id)
            ? Colors.lightBlue
            : widget.data.nodeColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _interfaceWidget(inputWidgets),
          const SizedBox(width: 8),
          widget.nodeTitleBuilder?.call(context, widget.data) ??
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
}
