import 'package:ai_gen/node_package/data/vs_node_data_provider.dart';
import 'package:ai_gen/node_package/widgets/GridCubit/grid_cubit.dart';
import 'package:ai_gen/node_package/widgets/Resuable%20Widgets/custom_button.dart';
import 'package:ai_gen/node_package/widgets/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'CustomWIdgets/floating_buttons.dart';
import 'GridPainter/grid_painter.dart';

class InteractiveVSNodeView extends StatelessWidget {
  final double width;
  final double height;
  final VSNodeDataProvider nodeDataProvider;

  const InteractiveVSNodeView({
    super.key,
    required this.width,
    required this.height,
    required this.nodeDataProvider,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GridCubit(),
      child: _InteractiveVSNodeViewBody(
        width: width,
        height: height,
        nodeDataProvider: nodeDataProvider,
      ),
    );
  }
}

class _InteractiveVSNodeViewBody extends StatefulWidget {
  final double width;
  final double height;
  final VSNodeDataProvider nodeDataProvider;

  const _InteractiveVSNodeViewBody({
    required this.width,
    required this.height,
    required this.nodeDataProvider,
  });

  @override
  State<_InteractiveVSNodeViewBody> createState() =>
      _InteractiveVSNodeViewBodyState();
}

class _InteractiveVSNodeViewBodyState
    extends State<_InteractiveVSNodeViewBody> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _transformationController.addListener(() {
      double zoomLevel =
          (_transformationController.value.getMaxScaleOnAxis() * 100)
              .clamp(5, 500);

      if (zoomLevel != context.read<GridCubit>().state.zoomLevel) {
        context.read<GridCubit>().updateZoom(zoomLevel);
      }

      double newSpacing = (zoomLevel / 10).clamp(10, 100);
      if (newSpacing != context.read<GridCubit>().state.gridSpacing) {
        context.read<GridCubit>().updateSpacing(newSpacing);
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridCubit, GridState>(
      builder: (context, state) {
        return Stack(
          children: [
            InteractiveViewer(
              maxScale: 5.0,
              minScale: 0.2,
              panEnabled: true,
              scaleEnabled: true,
              constrained: false,
              // transformationController: _transformationController,
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: Stack(children: [
                  if (state.showGrid)
                    CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: GridPainter(
                        gridSpacing: 30,
                        gridColor: state.gridColor,
                      ),
                    ),
                  VSNodeView(nodeDataProvider: widget.nodeDataProvider),
                ]),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height / 30,
              right: MediaQuery.of(context).size.width / 2 - 100,
              child: const FLoatingWIdgets(),
            ),
            Positioned(
              right: 50,
              bottom: 90,
              child: Container(
                width: 57,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xffE6E6E6),
                ),
                child: Column(
                  children: [
                    CustomButton(
                        onTap: () {
                          // double newZoom = (state.zoomLevel + 5).clamp(5, 500);
                          // context.read<GridCubit>().updateZoom(newZoom);
                          // _transformationController.value = Matrix4.identity()
                          //   ..scale(newZoom / 100);
                        },
                        width: 40,
                        height: 40,
                        backgroundColor: const Color(0xffCCCCCC),
                        icon: Icons.add,
                        borderRadius: 8,
                        iconColor: Colors.black,
                        iconSize: 25),
                    const SizedBox(height: 10),
                    BlocSelector<GridCubit, GridState, double>(
                      selector: (state) => state.zoomLevel,
                      builder: (context, zoomLevel) {
                        return Text(
                          zoomLevel.toStringAsFixed(0),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                        onTap: () {
                          // double newZoom = (state.zoomLevel - 5).clamp(5, 500);
                          // context.read<GridCubit>().updateZoom(newZoom);
                          // _transformationController.value = Matrix4.identity()
                          //   ..scale(newZoom / 100);
                        },
                        width: 40,
                        height: 40,
                        backgroundColor: const Color(0xffCCCCCC),
                        icon: Icons.remove,
                        borderRadius: 8,
                        iconColor: Colors.black,
                        iconSize: 25)
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/*
 Positioned(
              bottom: 80,
              right: 20,
              child: BlocBuilder<GridCubit, GridState>(
                buildWhen: (previous, current) =>
                    previous.showGrid != current.showGrid,
                builder: (context, state) {
                  return InkWell(
                    onTap: () {
                      context.read<GridCubit>().toggleGrid();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xff349CFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: state.showGrid
                          ? const Icon(Icons.grid_4x4_sharp,
                              color: Colors.white, size: 25)
                          : const Icon(Icons.grid_off_rounded,
                              color: Colors.white, size: 25),
                    ),
                  );
                },
              ),
            ),
*/
