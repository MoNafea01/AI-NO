import 'package:flutter/material.dart';

import '../common.dart';
import '../data/vs_interface.dart';
import '../data/vs_node_data_provider.dart';
import '../special_nodes/vs_list_node.dart';

class VSNodeInput extends StatefulWidget {
  ///Base node input widget
  ///
  ///Used in [VSNode]
  ///
  ///Uses [DragTarget] to accept [VSOutputData]
  const VSNodeInput({
    required this.data,
    super.key,
  });

  final VSInputData data;

  @override
  State<VSNodeInput> createState() => _VSNodeInputState();
}

class _VSNodeInputState extends State<VSNodeInput> {
  RenderBox? renderBox;
  final GlobalKey _anchor = GlobalKey();

  @override
  void initState() {
    super.initState();

    updateRenderBox();
  }

  @override
  void didUpdateWidget(covariant VSNodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data.widgetOffset == null ||
        widget.data.nodeData is VSListNode) {
      updateRenderBox();
    }
  }

  void updateRenderBox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      renderBox = findAndUpdateWidgetPosition(
        widgetAnchor: _anchor,
        context: context,
        data: widget.data,
      );
    });
  }

  void updateConnectedNode(VSOutputData? data) {
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
        DragTarget<VSOutputData>(
          builder: (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) {
            return GestureDetector(
              onTap: () {
                updateConnectedNode(null);
              },
              child: wrapWithToolTip(
                toolTip: widget.data.toolTip,
                child: widget.data.getInterfaceIcon(
                  context: context,
                  anchor: _anchor,
                ),
              ),
            );
          },
          onWillAcceptWithDetails: (details) {
            return widget.data.acceptInput(details.data);
          },
          onAcceptWithDetails: (details) {
            updateConnectedNode(details.data);
          },
        ),
        Text(widget.data.title),
      ],
    );
  }
}
