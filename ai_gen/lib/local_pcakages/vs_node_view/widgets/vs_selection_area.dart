import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vs_node_data_provider.dart';

class VSSelectionArea extends StatefulWidget {
  ///The base selection area
  ///
  ///Used inside [VSNodeView] to add a selction area to the node view
  ///
  ///Hold "Alt" to select items or unselect seleted items
  const VSSelectionArea({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<VSSelectionArea> createState() => _VSSelectionAreaState();
}

class _VSSelectionAreaState extends State<VSSelectionArea> {
  //If selectionMode is active
  bool selectionMode = false;

  //Raw input as delivered by  user
  Offset? startPos;
  Offset? endPos;

  //Inputs normalized to always have smalest values as top left and biggest as bottom right
  Offset? topLeftPos;
  Offset? bottomRightPos;

  late VSNodeDataProvider provider;

  @override
  void initState() {
    super.initState();

    provider = VSNodeDataProvider.of(context);
    HardwareKeyboard.instance.addHandler(handleKeyInput);
  }

  @override
  void dispose() {
    super.dispose();
    HardwareKeyboard.instance.removeHandler(handleKeyInput);
  }

  ///Takes keyboard input and sets [mode] accordingly
  bool handleKeyInput(KeyEvent input) {
    if (HardwareKeyboard.instance.isAltPressed) {
      setState(() {
        selectionMode = true;
      });
    } else {
      resetState();
    }

    return false;
  }

  ///Takes user input and sets [topLeftPos] an [bottomRightPos] accordingly
  void setNormedPositions() {
    late double startPosX;
    late double startPosY;

    late double endPosX;
    late double endPosY;

    if (startPos!.dx < endPos!.dx) {
      startPosX = startPos!.dx;
      endPosX = endPos!.dx;
    } else {
      startPosX = endPos!.dx;
      endPosX = startPos!.dx;
    }

    if (startPos!.dy < endPos!.dy) {
      startPosY = startPos!.dy;
      endPosY = endPos!.dy;
    } else {
      startPosY = endPos!.dy;
      endPosY = startPos!.dy;
    }

    topLeftPos = Offset(startPosX, startPosY);
    bottomRightPos = Offset(endPosX, endPosY);
  }

  ///Resets state to default values
  void resetState() {
    setState(
      () {
        topLeftPos = null;
        bottomRightPos = null;
        startPos = null;
        endPos = null;
        selectionMode = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (startPos != null && endPos != null) {
      setNormedPositions();

      children.add(
        Positioned(
          left: topLeftPos!.dx,
          top: topLeftPos!.dy,
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(
                115,
                0,
                204,
                255,
              ),
            ),
            width: bottomRightPos!.dx - topLeftPos!.dx,
            height: bottomRightPos!.dy - topLeftPos!.dy,
          ),
        ),
      );
    }

    children.add(widget.child);

    return selectionMode == false
        ? widget.child
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              setState(
                () => startPos = provider.applyViewPortTransfrom(
                  details.globalPosition,
                ),
              );
            },
            onPanUpdate: (details) {
              setState(
                () => endPos = provider.applyViewPortTransfrom(
                  details.globalPosition,
                ),
              );
            },
            onPanEnd: (details) {
              final nodes = provider
                  .findNodesInsideSelectionArea(
                    topLeftPos!,
                    bottomRightPos!,
                  )
                  .map((e) => e.id)
                  .toList();

              if (selectionMode) {
                final Set<String> alreadySelected = {};

                nodes.removeWhere(
                  (node) {
                    if (provider.selectedNodes.contains(node)) {
                      alreadySelected.add(node);
                      return true;
                    }
                    return false;
                  },
                );

                provider.removeSelectedNodes(alreadySelected);
                provider.addSelectedNodes(nodes);
              }

              resetState();
            },
            child: Stack(
              children: children,
            ),
          );
  }
}
