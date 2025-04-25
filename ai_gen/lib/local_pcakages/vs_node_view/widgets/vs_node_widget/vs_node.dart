import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'node_content.dart';

class VSNode extends StatefulWidget {
  const VSNode({
    required this.data,
    this.nodeTitleBuilder,
    super.key,
  });

  final VSNodeData data;

  final Widget Function(
    BuildContext context,
    VSNodeData nodeData,
  )? nodeTitleBuilder;

  @override
  State<VSNode> createState() => _VSNodeState();
}

class _VSNodeState extends State<VSNode> {
  late final GlobalKey _anchor;
  late final GlobalKey _key2;
  late final VSNodeDataProvider nodeProvider;

  @override
  void initState() {
    _anchor = GlobalKey();
    _key2 = GlobalKey();
    nodeProvider = VSNodeDataProvider.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDragUpdate: _whileDragging,
      childWhenDragging: const SizedBox(),
      feedback: _draggedNode(),
      child: _node(),
    );
  }

  void _whileDragging(details) {
    if (_anchor.currentContext == null) return;

    final RenderBox renderBox =
        _anchor.currentContext?.findRenderObject() as RenderBox;
    Offset newPosition = renderBox.localToGlobal(Offset.zero);
    nodeProvider.moveNode(widget.data, newPosition);
  }

  Widget _draggedNode() {
    if (!mounted) return const SizedBox();

    return Transform.scale(
      scale: 1 / nodeProvider.viewportScale,
      child: Material(
        key: _key2,
        borderRadius: BorderRadius.circular(12),
        child: InheritedNodeDataProvider(
          provider: nodeProvider,
          child: NodeContent(
            nodeProvider: nodeProvider,
            data: widget.data,
            anchor: _anchor,
          ),
        ),
      ),
    );
  }

  GestureDetector _node() {
    return GestureDetector(
      onDoubleTap: () {
        context
            .read<GridNodeViewCubit>()
            .updateActiveNodePropertiesCard(widget.data.node);
      },
      onSecondaryTapUp: _popMenu,
      child: NodeContent(
        nodeProvider: nodeProvider,
        data: widget.data,
        anchor: _anchor,
      ),
    );
  }

  void _popMenu(details) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: const [
        PopupMenuItem(value: 'properties', child: Text('Properties')),
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'properties') {
        context
            .read<GridNodeViewCubit>()
            .updateActiveNodePropertiesCard(widget.data.node);
      } else if (value == 'rename') {
        setState(() => widget.data.isRenaming = true);
      } else if (value == 'delete') {
        setState(() {
          widget.data.deleteNode?.call();
          nodeProvider.removeNodes([widget.data]);
        });
      }
    });
  }
}
