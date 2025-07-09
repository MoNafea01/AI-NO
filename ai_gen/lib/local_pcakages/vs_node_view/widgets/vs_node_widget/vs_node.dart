import 'dart:math';

import 'package:ai_gen/core/data/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/utils/reusable_widgets/custom_menu_item.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/cubit/grid_node_view_cubit.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'node_content.dart';

class VSNode extends StatefulWidget {
  const VSNode({
    required this.data,
    this.nodeTitleBuilder,
    super.key,
  });

  final VSNodeData data;
  final Widget Function(BuildContext context, VSNodeData nodeData)?
      nodeTitleBuilder;

  @override
  State<VSNode> createState() => _VSNodeState();
}

class _VSNodeState extends State<VSNode> with AutomaticKeepAliveClientMixin {
  late final GlobalKey<NodeContentState> _nodeAnchorKey;
  late final GlobalKey _draggedNodeKey;
  late final VSNodeDataProvider _nodeProvider;
  List<PopupMenuEntry>? _cachedMenuItems;

  @override
  bool get wantKeepAlive => true;
  late Widget nodeContent;

  double _rotationAngle = 0;
  bool _isRotating = false;
  Offset? _rotationStart;

  @override
  void initState() {
    super.initState();
    _nodeAnchorKey = GlobalKey<NodeContentState>();
    _draggedNodeKey = GlobalKey();
    _nodeProvider = VSNodeDataProvider.of(context);
    nodeContent = NodeContent(
      nodeProvider: _nodeProvider,
      data: widget.data,
      key: _nodeAnchorKey,
    );
  }

  void focusTitle() {
    _nodeAnchorKey.currentState?.focusTitle();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Draggable<VSNodeData>(
      data: widget.data,
      onDragUpdate: !_isRotating ? _handleNodeDrag : null,
      childWhenDragging: const SizedBox.shrink(),
      feedback: _buildDraggedNode(),
      child: _buildNode(),
    );
  }

  void _handleNodeDrag(DragUpdateDetails details) {
    if (!mounted || _nodeAnchorKey.currentContext == null) return;

    final nodeContentState = _nodeAnchorKey.currentContext
        ?.findAncestorStateOfType<NodeContentState>();
    nodeContentState?.updateOutputs();
    final RenderBox renderBox =
        _nodeAnchorKey.currentContext?.findRenderObject() as RenderBox;
    final Offset newPosition = renderBox.localToGlobal(Offset.zero);
    _nodeProvider.moveNode(widget.data, newPosition);
  }

  Widget _buildDraggedNode() {
    if (!mounted) return const SizedBox.shrink();

    return InheritedNodeDataProvider(
      provider: _nodeProvider,
      child: Transform.scale(
        scale: 1 / _nodeProvider.viewportScale,
        child: Material(
          key: _draggedNodeKey,
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          child: _rotatedContent(),
        ),
      ),
    );
  }

  Widget _buildNode() {
    return GestureDetector(
      onDoubleTap: _handleNodeProperties,
      onSecondaryTapUp: _showContextMenu,
      onPanStart: _isRotating ? _startRotation : null,
      onPanUpdate: _isRotating ? _updateRotation : null,
      onPanEnd: _isRotating ? _endRotation : null,
      child: _rotatedContent(),
    );
  }

  Widget _rotatedContent() {
    return Transform.rotate(
      angle: _rotationAngle,
      child: nodeContent,
    );
  }

  void _handleNodeProperties() {
    context
        .read<GridNodeViewCubit>()
        .updateActiveNodePropertiesCard(widget.data.node);
  }

  void _showContextMenu(TapUpDetails details) {
    showMenu(
      color: AppColors.grey100,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: AppColors.grey100,
      elevation: 8,
      menuPadding: const EdgeInsets.all(4),
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: _getMenuItems(),
    );
  }

  List<PopupMenuEntry> _getMenuItems() {
    return _cachedMenuItems ??= [
      _buildMenuItem(
        'properties',
        onTap: _handleNodeProperties,
      ),
      _buildMenuItem(
        'rename',
        onTap: () => setState(() {
          widget.data.isRenaming = true;
          focusTitle();
        }),
      ),
      // _buildMenuItem(
      //   'rotate',
      //   onTap: () => setState(() {
      //     _isRotating = true;
      //   }),
      // ),
      _buildMenuItem(
        'delete',
        onTap: _handleNodeDeletion,
      ),
    ];
  }

  void _handleNodeDeletion() {
    final INodeServices nodeServerCalls = GetIt.I.get<INodeServices>();
    final NodeModel? nodeModel = widget.data.node;

    if (nodeModel?.nodeId != null) {
      nodeServerCalls.deleteNode(nodeModel!);
    }

    widget.data.deleteNode?.call();
    _nodeProvider.removeNodes([widget.data]);
    setState(() {});
  }

  CustomMenuItem _buildMenuItem(String value, {VoidCallback? onTap}) =>
      CustomMenuItem(
        value,
        onTap: onTap,
        childAlignment: Alignment.centerLeft,
        child: Text(value, style: AppTextStyles.black14Bold),
      );

  void _startRotation(DragStartDetails details) {
    _rotationStart = details.globalPosition;
  }

  void _updateRotation(DragUpdateDetails details) {
    if (_rotationStart == null) return;

    final center =
        (_nodeAnchorKey.currentContext?.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero) +
            Offset(
              (_nodeAnchorKey.currentContext?.size?.width ?? 0) / 2,
              (_nodeAnchorKey.currentContext?.size?.height ?? 0) / 2,
            );

    final dx1 = _rotationStart!.dx - center.dx;
    final dy1 = _rotationStart!.dy - center.dy;

    final dx2 = details.globalPosition.dx - center.dx;
    final dy2 = details.globalPosition.dy - center.dy;

    final angle1 = atan2(dy1, dx1);
    final angle2 = atan2(dy2, dx2);

    setState(() {
      _rotationAngle += angle2 - angle1;
    });

    _rotationStart = details.globalPosition;
  }

  void _endRotation(DragEndDetails details) {
    setState(() {
      _isRotating = false;
      _rotationStart = null;
    });
  }
}
