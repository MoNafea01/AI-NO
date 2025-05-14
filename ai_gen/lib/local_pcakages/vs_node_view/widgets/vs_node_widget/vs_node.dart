import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/reusable_widgets/custom_menu_item.dart';
import 'package:ai_gen/core/services/app_services.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'node_content.dart';

/// A widget that represents a node in the visual scripting interface.
///
/// This widget handles the visual representation and interaction of a node,
/// including dragging, context menu, and node operations. It supports:
/// - Dragging nodes to reposition them
/// - Double-tap to edit node properties
/// - Right-click context menu for additional operations
/// - Custom node title rendering
class VSNode extends StatefulWidget {
  /// Creates a new [VSNode] instance.
  ///
  /// [data] is required and contains the node's data and state.
  /// [nodeTitleBuilder] is optional and can be used to customize the node's title.
  const VSNode({
    required this.data,
    this.nodeTitleBuilder,
    super.key,
  });

  /// The data associated with this node
  final VSNodeData data;

  /// Optional builder for customizing the node title
  final Widget Function(BuildContext context, VSNodeData nodeData)?
      nodeTitleBuilder;

  @override
  State<VSNode> createState() => _VSNodeState();
}

class _VSNodeState extends State<VSNode> with AutomaticKeepAliveClientMixin {
  /// Key for the node's anchor point
  late final GlobalKey<NodeContentState> _nodeAnchorKey;

  /// Key for the dragged node's material
  late final GlobalKey _draggedNodeKey;

  /// The provider that manages node data and state
  late final VSNodeDataProvider _nodeProvider;

  /// Cache for menu items to avoid rebuilding
  List<PopupMenuEntry>? _cachedMenuItems;

  @override
  bool get wantKeepAlive => true;
  late Widget nodeContent;

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
      onDragUpdate: _handleNodeDrag,
      childWhenDragging: const SizedBox.shrink(),
      feedback: _buildDraggedNode(),
      child: _buildNode(),
    );
  }

  /// Handles node movement during drag operations
  void _handleNodeDrag(DragUpdateDetails details) {
    if (!mounted || _nodeAnchorKey.currentContext == null) return;

    // Find the NodeContent state and trigger output update
    final nodeContentState = _nodeAnchorKey.currentContext
        ?.findAncestorStateOfType<NodeContentState>();

    nodeContentState?.updateOutputs();
    final RenderBox renderBox =
        _nodeAnchorKey.currentContext?.findRenderObject() as RenderBox;
    final Offset newPosition = renderBox.localToGlobal(Offset.zero);
    _nodeProvider.moveNode(widget.data, newPosition);
  }

  /// Builds the node's visual representation when being dragged
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
          child: nodeContent,
        ),
      ),
    );
  }

  /// Builds the node's main visual representation
  Widget _buildNode() {
    return GestureDetector(
      onDoubleTap: _handleNodeProperties,
      onSecondaryTapUp: _showContextMenu,
      child: nodeContent,
    );
  }

  /// Handles double-tap to edit node properties
  void _handleNodeProperties() {
    context
        .read<GridNodeViewCubit>()
        .updateActiveNodePropertiesCard(widget.data.node);
  }

  /// Shows the node's context menu
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

  /// Gets the list of menu items for the context menu
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
      _buildMenuItem(
        'delete',
        onTap: _handleNodeDeletion,
      ),
    ];
  }

  /// Handles node deletion
  void _handleNodeDeletion() {
    final AppServices nodeServerCalls = GetIt.I.get<AppServices>();
    final NodeModel? nodeModel = widget.data.node;

    if (nodeModel?.nodeId != null) {
      nodeServerCalls.deleteNode(nodeModel!);
    }

    widget.data.deleteNode?.call();
    _nodeProvider.removeNodes([widget.data]);
    setState(() {});
  }

  /// Builds a custom menu item for the context menu
  CustomMenuItem _buildMenuItem(String value, {VoidCallback? onTap}) =>
      CustomMenuItem(
        value,
        onTap: onTap,
        childAlignment: Alignment.centerLeft,
        child: Text(value, style: AppTextStyles.black14Bold),
      );
}
