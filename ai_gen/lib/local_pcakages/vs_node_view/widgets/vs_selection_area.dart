import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vs_node_data_provider.dart';

/// A widget that provides a selection area for nodes in the visual scripting interface.
///
/// This widget allows users to select multiple nodes by drawing a selection rectangle
/// while holding the Alt key. The selection area is visually represented by a semi-transparent
/// blue rectangle, and nodes within this area can be selected or deselected.
class VSSelectionArea extends StatefulWidget {
  /// Creates a new [VSSelectionArea] instance.
  ///
  /// [child] is required and represents the content that will be selectable.
  const VSSelectionArea({
    required this.child,
    super.key,
  });

  /// The widget that will be wrapped with selection functionality
  final Widget child;

  @override
  State<VSSelectionArea> createState() => _VSSelectionAreaState();
}

/// The state for the [VSSelectionArea] widget.
///
/// This state class manages the selection area's position, state, and interaction.
class _VSSelectionAreaState extends State<VSSelectionArea> {
  /// Whether the selection mode is currently active
  bool _isSelectionModeActive = false;

  /// The starting position of the selection rectangle
  Offset? _selectionStart;

  /// The current position of the selection rectangle
  Offset? _selectionEnd;

  /// The normalized top-left position of the selection rectangle
  Offset? _selectionTopLeft;

  /// The normalized bottom-right position of the selection rectangle
  Offset? _selectionBottomRight;

  /// The provider that manages node data and selection state
  late final VSNodeDataProvider _provider;

  /// The color of the selection rectangle
  static const Color _selectionColor = Color.fromARGB(115, 0, 204, 255);

  @override
  void initState() {
    super.initState();
    _provider = VSNodeDataProvider.of(context);
    HardwareKeyboard.instance.addHandler(_handleKeyInput);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyInput);
    super.dispose();
  }

  /// Handles keyboard input to toggle selection mode
  bool _handleKeyInput(KeyEvent input) {
    if (HardwareKeyboard.instance.isAltPressed) {
      setState(() => _isSelectionModeActive = true);
    } else {
      _resetSelectionState();
    }
    return false;
  }

  /// Normalizes the selection rectangle coordinates
  void _normalizeSelectionCoordinates() {
    if (_selectionStart == null || _selectionEnd == null) return;

    final startX = _selectionStart!.dx;
    final startY = _selectionStart!.dy;
    final endX = _selectionEnd!.dx;
    final endY = _selectionEnd!.dy;

    _selectionTopLeft = Offset(
      startX < endX ? startX : endX,
      startY < endY ? startY : endY,
    );

    _selectionBottomRight = Offset(
      startX < endX ? endX : startX,
      startY < endY ? endY : startY,
    );
  }

  /// Resets the selection state to its initial values
  void _resetSelectionState() {
    setState(() {
      _selectionTopLeft = null;
      _selectionBottomRight = null;
      _selectionStart = null;
      _selectionEnd = null;
      _isSelectionModeActive = false;
    });
  }

  /// Handles the end of a selection gesture
  void _handleSelectionEnd() {
    if (_selectionTopLeft == null || _selectionBottomRight == null) return;

    final selectedNodeIds = _provider
        .findNodesInsideSelectionArea(
          _selectionTopLeft!,
          _selectionBottomRight!,
        )
        .map((node) => node.id)
        .toList();

    if (_isSelectionModeActive) {
      final alreadySelectedNodes = <String>{};

      // Remove nodes that are already selected
      selectedNodeIds.removeWhere((nodeId) {
        if (_provider.selectedNodes.contains(nodeId)) {
          alreadySelectedNodes.add(nodeId);
          return true;
        }
        return false;
      });

      _provider.removeSelectedNodes(alreadySelectedNodes);
      _provider.addSelectedNodes(selectedNodeIds);
    }

    _resetSelectionState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSelectionModeActive) {
      return widget.child;
    }

    final List<Widget> children = [widget.child];

    if (_selectionStart != null && _selectionEnd != null) {
      _normalizeSelectionCoordinates();

      children.insert(
        0,
        Positioned(
          left: _selectionTopLeft!.dx,
          top: _selectionTopLeft!.dy,
          child: Container(
            decoration: const BoxDecoration(
              color: _selectionColor,
            ),
            width: _selectionBottomRight!.dx - _selectionTopLeft!.dx,
            height: _selectionBottomRight!.dy - _selectionTopLeft!.dy,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        setState(() {
          _selectionStart = _provider.applyViewPortTransfrom(
            details.globalPosition,
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _selectionEnd = _provider.applyViewPortTransfrom(
            details.globalPosition,
          );
        });
      },
      onPanEnd: (_) => _handleSelectionEnd(),
      child: Stack(children: children),
    );
  }
}
