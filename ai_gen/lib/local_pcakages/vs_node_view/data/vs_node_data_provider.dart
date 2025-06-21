import 'package:flutter/material.dart';

import '../common.dart';
import '../vs_node_view.dart';

/// Represents the context for a context menu in the node view.
///
/// This class keeps track of where the context menu is positioned in 2D space
/// and whether it was opened through a node reference.
class ContextMenuContext {
  ContextMenuContext({
    required this.offset,
    this.reference,
  });

  /// The position of the context menu in the viewport
  final Offset offset;

  /// Optional reference to the output data that triggered the context menu
  final VSOutputData? reference;
}

/// A provider class that manages the state and interactions of nodes in the visual scripting interface.
///
/// This class wraps [VSNodeManager] to provide UI interaction capabilities and state management.
/// It handles node creation, movement, selection, and context menu operations.
class VSNodeDataProvider extends ChangeNotifier {
  /// Creates a new [VSNodeDataProvider].
  ///
  /// [nodeManager] is required and manages the actual node data.
  /// [historyManager] is optional and provides undo/redo functionality.
  /// [withAppbar] determines if the view includes an app bar.
  /// [appbarHeight] specifies the height of the app bar if enabled.
  VSNodeDataProvider({
    required this.nodeManager,
    this.historyManager,
    this.withAppbar = false,
    this.appbarHeight = 56,
  }) {
    if (historyManager != null) {
      historyManager!.provider = this;
      historyManager!.updateHistory();
    }
  }

  /// Whether the view includes an app bar
  final bool withAppbar;

  /// The height of the app bar if enabled
  final double appbarHeight;

  /// Controller for viewport transformations
  late final TransformationController transformationController;

  /// Gets the closest [VSNodeDataProvider] from the widget tree
  static VSNodeDataProvider of(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<InheritedNodeDataProvider>()!
        .provider;
  }

  /// The node manager instance that holds all node data
  final VSNodeManager nodeManager;

  /// Optional history manager for undo/redo functionality
  final VSHistoryManger? historyManager;

  /// Map of all available node builders
  Map<String, dynamic> get nodeBuildersMap => nodeManager.nodeBuildersMap;

  /// Map of all current nodes indexed by their IDs
  Map<String, VSNodeData> get nodes => nodeManager.nodes;

  /// Loads nodes from a serialized string and replaces current nodes
  void loadSerializedNodes(String serializedNodes) {
    nodeManager.loadLocalSerializedNodes(serializedNodes);
    notifyListeners();
  }

  /// Updates existing nodes or creates new ones
  Future<void> updateOrCreateNodes(
    List<VSNodeData> nodeDatas, {
    bool updateHistory = true,
  }) async {
    nodeManager.updateOrCreateNodes(nodeDatas);
    if (updateHistory) {
      historyManager?.updateHistory();
    }
    notifyListeners();
  }

  /// Moves one or multiple nodes based on the provided offset
  void moveNode(VSNodeData nodeData, Offset offset) {
    // Update the node's offset in the scene
    nodeData.node?.offset = transformationController.toScene(offset);

    final movedOffset = applyViewPortTransfrom(offset) - nodeData.widgetOffset;
    final List<VSNodeData> modifiedNodes = [];

    if (selectedNodes.contains(nodeData.id)) {
      // Move all selected nodes
      for (final nodeId in selectedNodes) {
        final currentNode = nodes[nodeId]!;
        modifiedNodes.add(
          currentNode..widgetOffset = currentNode.widgetOffset + movedOffset,
        );
      }
    } else {
      // Move only the specified node
      modifiedNodes.add(
        nodeData..widgetOffset = nodeData.widgetOffset + movedOffset,
      );
    }

    updateOrCreateNodes(modifiedNodes);
  }

  /// Removes multiple nodes from the view
  Future<void> removeNodes(List<VSNodeData> nodeDatas) async {
    nodeManager.removeNodes(nodeDatas);
    historyManager?.updateHistory();
    notifyListeners();
  }

  /// Clears all nodes from the view
  Future<void> clearNodes() async {
    nodeManager.clearNodes();
    historyManager?.updateHistory();
    notifyListeners();
  }

  /// Creates a new node based on the builder and current context menu position
  void createNodeFromContext(VSNodeDataBuilder builder) {
    if (_contextMenuContext == null) return;

    final nodeData = builder(
      _contextMenuContext!.offset,
      _contextMenuContext!.reference,
    );

    nodeData.node?.offset =
        transformationController.toScene(_contextMenuContext!.offset);
    updateOrCreateNodes([nodeData]);
  }

  /// Creates a new node from the sidebar at a specified position
  void createNodeFromSidebar(
    VSNodeDataBuilder builder, {
    Offset offset = const Offset(250, 250),
  }) {
    final movedOffset = applyViewPortTransfrom(offset);
    final nodeData = builder(movedOffset, null);
    nodeData.node?.offset = transformationController.toScene(offset);

    updateOrCreateNodes([nodeData]);
  }

  /// Set of currently selected node IDs
  Set<String> get selectedNodes => _selectedNodes;
  Set<String> _selectedNodes = {};

  set selectedNodes(Set<String> data) {
    _selectedNodes = Set.from(data);
    notifyListeners();
  }

  /// Adds nodes to the current selection
  void addSelectedNodes(Iterable<String> data) {
    selectedNodes = selectedNodes..addAll(data);
  }

  /// Removes nodes from the current selection
  void removeSelectedNodes(Iterable<String> data) {
    selectedNodes =
        selectedNodes.where((element) => !data.contains(element)).toSet();
  }

  /// Finds all nodes that fall within a selection area
  Set<VSNodeData> findNodesInsideSelectionArea(Offset start, Offset end) {
    final Set<VSNodeData> inside = {};
    for (final node in nodeManager.nodes.values) {
      final pos = node.widgetOffset;
      if (pos.dy > start.dy &&
          pos.dx > start.dx &&
          pos.dy < end.dy &&
          pos.dx < end.dx) {
        inside.add(node);
      }
    }
    return inside;
  }

  /// Current context menu context
  ContextMenuContext? _contextMenuContext;
  ContextMenuContext? get contextMenuContext => _contextMenuContext;

  /// Viewport offset for UI positioning
  Offset viewportOffset = Offset.zero;

  /// Current viewport scale
  double get viewportScale => _viewportScale;
  double _viewportScale = 1;

  set viewportScale(double value) {
    _viewportScale = value;
    notifyListeners();
  }

  /// Applies viewport transformation to a position
  Offset applyViewPortTransfrom(Offset initial) {
    return withAppbar
        ? (initial - Offset(0, appbarHeight) - viewportOffset) * viewportScale
        : (initial - viewportOffset) * viewportScale;
  }

  /// Opens the context menu at the specified position
  void openContextMenu({
    required Offset position,
    VSOutputData? outputData,
  }) {
    _contextMenuContext = ContextMenuContext(
      offset: applyViewPortTransfrom(position),
      reference: outputData,
    );
    notifyListeners();
  }

  /// Closes the context menu
  void closeContextMenu() {
    _contextMenuContext = null;
    notifyListeners();
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }
}
