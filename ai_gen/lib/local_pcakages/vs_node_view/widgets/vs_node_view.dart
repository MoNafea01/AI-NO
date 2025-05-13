import 'package:flutter/material.dart';

import '../data/vs_interface.dart';
import '../data/vs_node_data.dart';
import '../data/vs_node_data_provider.dart';
import 'inherited_node_data_provider.dart';
import 'line_drawer/multi_gradiant_line_drawer.dart';
import 'vs_context_menu.dart';
import 'vs_node_widget/vs_node.dart';
import 'vs_selection_area.dart';

/// A widget that displays and manages a visual scripting interface.
///
/// This widget provides the main view for interacting with nodes, including:
/// - Displaying nodes and their connections
/// - Handling node selection and movement
/// - Managing the context menu
/// - Supporting node creation and deletion
class VSNodeView extends StatelessWidget {
  /// Creates a new [VSNodeView] instance.
  ///
  /// [nodeDataProvider] is required and manages the node data and state.
  /// [contextMenuBuilder] can be used to customize the context menu.
  /// [nodeBuilder] can be used to customize individual node widgets.
  /// [nodeTitleBuilder] can be used to customize node titles.
  /// [enableSelectionArea] determines if node selection is enabled.
  /// [selectionAreaBuilder] can be used to customize the selection area.
  /// [gestureDetectorBuilder] can be used to customize gesture handling.
  const VSNodeView({
    required this.nodeDataProvider,
    this.contextMenuBuilder,
    this.nodeBuilder,
    this.nodeTitleBuilder,
    this.enableSelectionArea = true,
    this.selectionAreaBuilder,
    this.gestureDetectorBuilder,
    super.key,
  });

  /// The provider that manages node data and state
  final VSNodeDataProvider nodeDataProvider;

  /// Optional builder for customizing individual node widgets
  final Widget Function(
    BuildContext context,
    VSNodeData data,
  )? nodeBuilder;

  /// Optional builder for customizing the context menu
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> nodeBuildersMap,
  )? contextMenuBuilder;

  /// Optional builder for customizing node titles
  final Widget Function(
    BuildContext context,
    VSNodeData nodeData,
  )? nodeTitleBuilder;

  /// Whether to enable node selection functionality
  final bool enableSelectionArea;

  /// Optional builder for customizing the selection area
  final Widget Function(
    BuildContext context,
    Widget view,
  )? selectionAreaBuilder;

  /// Optional builder for customizing gesture handling
  final GestureDetector Function(
    BuildContext context,
    VSNodeDataProvider nodeDataProvider,
  )? gestureDetectorBuilder;

  @override
  Widget build(BuildContext context) {
    return InheritedNodeDataProvider(
      provider: nodeDataProvider,
      child: ListenableBuilder(
        listenable: nodeDataProvider,
        builder: (context, _) {
          return _buildNodeView(context);
        },
      ),
    );
  }

  /// Builds the main node view with all its components
  Widget _buildNodeView(BuildContext context) {
    final nodes = _buildNodes(context);
    final view = Stack(
      children: [
        _buildGestureDetector(context),
        ...nodes,
        _buildConnectionLines(),
        if (nodeDataProvider.contextMenuContext != null)
          _buildContextMenu(context),
      ],
    );

    return enableSelectionArea ? _buildWithSelectionArea(context, view) : view;
  }

  /// Builds the list of positioned node widgets
  Iterable<Widget> _buildNodes(BuildContext context) {
    return nodeDataProvider.nodes.values.map(
      (VSNodeData value) {
        return Positioned(
          left: value.widgetOffset.dx,
          top: value.widgetOffset.dy,
          child: nodeBuilder?.call(context, value) ??
              VSNode(
                key: ValueKey(value.id),
                data: value,
                nodeTitleBuilder: nodeTitleBuilder,
              ),
        );
      },
    );
  }

  /// Builds the gesture detector for handling user interactions
  Widget _buildGestureDetector(BuildContext context) {
    return gestureDetectorBuilder?.call(context, nodeDataProvider) ??
        GestureDetector(
          onTapDown: (_) {
            nodeDataProvider.closeContextMenu();
            nodeDataProvider.selectedNodes = {};
          },
          onSecondaryTapUp: (details) => nodeDataProvider.openContextMenu(
            position: details.globalPosition,
          ),
          onLongPressStart: (details) => nodeDataProvider.openContextMenu(
            position: details.globalPosition,
          ),
        );
  }

  /// Builds the connection lines between nodes
  Widget _buildConnectionLines() {
    return CustomPaint(
      foregroundPainter: MultiGradientLinePainter(
        data: nodeDataProvider.nodes.values
            .expand<VSInputData>((element) => element.inputData)
            .toList(),
      ),
    );
  }

  /// Builds the context menu widget
  Widget _buildContextMenu(BuildContext context) {
    return Positioned(
      left: nodeDataProvider.contextMenuContext!.offset.dx,
      top: nodeDataProvider.contextMenuContext!.offset.dy,
      child: contextMenuBuilder?.call(
            context,
            nodeDataProvider.nodeBuildersMap,
          ) ??
          VSContextMenu(
            nodeBuilders: nodeDataProvider.nodeBuildersMap,
          ),
    );
  }

  /// Wraps the view with a selection area if enabled
  Widget _buildWithSelectionArea(BuildContext context, Widget view) {
    return selectionAreaBuilder?.call(context, view) ??
        VSSelectionArea(child: view);
  }
}
