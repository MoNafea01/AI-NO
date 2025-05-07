import 'package:flutter/material.dart';

import '../data/vs_node_data_provider.dart';
import 'grid_painter/grid_painter.dart';
import 'vs_node_view.dart';

class InteractiveVSNodeView extends StatefulWidget {
  ///Wraps [VSNodeView] in an [InteractiveViewer] this enables pan and zoom
  ///
  ///Creates a [SizedBox] of given width and height that will function as a canvas
  ///
  ///Width and height default to their coresponding screen dimension. If one of them is omited there will be no panning on that axis
  const InteractiveVSNodeView({
    required this.nodeDataProvider,
    required this.width,
    required this.height,
    this.scaleFactor = 500,
    this.maxScale = 2,
    this.minScale = 0.01,
    this.scaleEnabled = true,
    this.panEnabled = true,
    this.showGrid = true,
    this.gridSpacing,
    this.gridColor,
    this.baseNodeView,
    this.controller,
    super.key,
  });

  ///TransformationController used by the [InteractiveViewer] widget
  final TransformationController? controller;

  ///The provider that will be used to controll the UI
  final VSNodeDataProvider nodeDataProvider;

  ///Width of the canvas
  ///
  ///Defaults to screen width
  final double width;

  ///Height of the canvas
  ///
  ///Defaults to screen height
  final double height;

  /// Determines the amount of scale to be performed per pointer scroll.
  final double scaleFactor;

  /// The maximum allowed scale.
  final double maxScale;

  /// The minimum allowed scale.
  final double minScale;

  /// If false, the user will be prevented from panning.
  final bool panEnabled;

  /// If false, the user will be prevented from scaling.
  final bool scaleEnabled;

  ///The [VSNodeView] that will be wrapped by the [InteractiveViewer]
  final VSNodeView? baseNodeView;

  final bool showGrid;
  final Color? gridColor;
  final double? gridSpacing;

  @override
  State<InteractiveVSNodeView> createState() => _InteractiveVSNodeViewState();
}

class _InteractiveVSNodeViewState extends State<InteractiveVSNodeView> {
  late TransformationController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? TransformationController();
    widget.nodeDataProvider.transformationController = controller;

    //Needs to be done with a listener to assure inertia doesnt messup the offset
    controller.addListener(
      () {
        widget.nodeDataProvider.viewportScale =
            1 / controller.value.getMaxScaleOnAxis();

        widget.nodeDataProvider.viewportOffset = Offset(
          controller.value.getTranslation().x,
          controller.value.getTranslation().y,
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      final double x = (screenSize.width - widget.width) / 2;
      final double y = (screenSize.height - widget.height) / 2;

      controller.value = Matrix4.identity()..translate(x, y);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    double height = widget.height;
    return InteractiveViewer(
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      scaleFactor: widget.scaleFactor,
      scaleEnabled: widget.scaleEnabled,
      panEnabled: widget.panEnabled,
      constrained: false,
      transformationController: controller,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            if (widget.showGrid)
              GridPainter(
                width: width,
                height: height,
                color: widget.gridColor,
                spacing: widget.gridSpacing,
              ),
            widget.baseNodeView ??
                VSNodeView(
                  nodeDataProvider: widget.nodeDataProvider,
                ),
          ],
        ),
      ),
    );
  }
}
