import 'package:ai_gen/node_package/widgets/GridCubit/grid_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_gen/node_package/data/vs_node_data_provider.dart';
import 'package:ai_gen/node_package/widgets/vs_node_view.dart';

// class InteractiveVSNodeView extends StatefulWidget {
//   const InteractiveVSNodeView({
//     super.key,
//     this.controller,
//     this.width,
//     this.height,
//     this.scaleFactor = 1.2,
//     this.maxScale = 2,
//     this.minScale = 0.01,
//     this.scaleEnabled = true,
//     this.panEnabled = true,
//     required this.nodeDataProvider,
//     this.baseNodeView,
//   });

//   final TransformationController? controller;
//   final VSNodeDataProvider nodeDataProvider;
//   final double? width;
//   final double? height;
//   final double scaleFactor;
//   final double maxScale;
//   final double minScale;
//   final bool panEnabled;
//   final bool scaleEnabled;
//   final VSNodeView? baseNodeView;

//   @override
//   State<InteractiveVSNodeView> createState() => _InteractiveVSNodeViewState();
// }

// class _InteractiveVSNodeViewState extends State<InteractiveVSNodeView> {
//   late TransformationController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = widget.controller ?? TransformationController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final double width = widget.width ?? screenSize.width;
//     final double height = widget.height ?? screenSize.height;

//     controller.addListener(() {
//       widget.nodeDataProvider.viewportScale =
//           1 / controller.value.getMaxScaleOnAxis();
//       widget.nodeDataProvider.viewportOffset = Offset(
//         controller.value.getTranslation().x,
//         controller.value.getTranslation().y,
//       );
//     });

//     return BlocBuilder<GridCubit, GridState>(
//       builder: (context, state) {
//         return Stack(
//           children: [
//             if (state.showGrid)
//               CustomPaint(
//                 size: Size(width, height),
//                 painter: GridPainter(gridSpacing: state.gridSpacing),
//               ),
//             InteractiveViewer(
//               maxScale: widget.maxScale,
//               minScale: widget.minScale,
//               scaleFactor: widget.scaleFactor,
//               scaleEnabled: widget.scaleEnabled,
//               panEnabled: widget.panEnabled,
//               constrained: false,
//               transformationController: controller,
//               child: SizedBox(
//                 width: width,
//                 height: height,
//                 child: widget.baseNodeView ??
//                     VSNodeView(nodeDataProvider: widget.nodeDataProvider),
//               ),
//             ),
//             Positioned(
//               top: 10,
//               right: 10,
//               child: Column(
//                 children: [
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: WidgetStateProperty.all<Color>(
//                           const Color.fromARGB(255, 227, 224, 220)),
//                       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           side: const BorderSide(
//                               color: Colors.black,
//                               width: 2), // Set border color to black
//                           borderRadius: BorderRadius.circular(
//                               20), // Optional: border radius
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       context.read<GridCubit>().toggleGrid();
//                     },
//                     child: Text(
//                       state.showGrid ? "Hide Grid" : "Show Grid",
//                       style: const TextStyle(color: Colors.black, fontSize: 15),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       backgroundColor: WidgetStateProperty.all<Color>(
//                           const Color.fromARGB(255, 227, 224, 220)),
//                       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           side: const BorderSide(
//                               color: Colors.black,
//                               width: 2), // Set border color to black
//                           borderRadius: BorderRadius.circular(
//                               20), // Optional: border radius
//                         ),
//                       ),
//                     ),
//                     onPressed: () {
//                       context.read<GridCubit>().updateGridSpacing(
//                           state.gridSpacing == 20.0 ? 30.0 : 20.0);
//                     },
//                     child: const Text(
//                       "Change Grid Spacing",
//                       style: TextStyle(color: Colors.black, fontSize: 15),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
/// Main interactive view with required parameters/// Interactive View
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
  State<_InteractiveVSNodeViewBody> createState() => _InteractiveVSNodeViewBodyState();
}

class _InteractiveVSNodeViewBodyState extends State<_InteractiveVSNodeViewBody> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _transformationController.addListener(() {
      double zoomLevel = 1 / _transformationController.value.getMaxScaleOnAxis();
      context.read<GridCubit>().updateZoom(zoomLevel);
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
            if (state.showGrid)
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: GridPainter(gridSpacing: state.gridSpacing, gridColor: state.gridColor),
              ),

            InteractiveViewer(
              maxScale: 2.0,
              minScale: 0.01,
              panEnabled: true,
              scaleEnabled: true,
              constrained: false,
              transformationController: _transformationController,
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: VSNodeView(nodeDataProvider: widget.nodeDataProvider),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => context.read<GridCubit>().toggleGrid(),
                    child: Text(state.showGrid ? "Hide Grid" : "Show Grid"),
                  ),
                  const SizedBox(height: 10),

                  // **Grid Spacing Stepper**
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text("Grid Spacing"),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (state.gridSpacing > 5) {
                                    context.read<GridCubit>().updateSpacing(state.gridSpacing - 5);
                                  }
                                },
                              ),
                              Text(state.gridSpacing.toStringAsFixed(0)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  context.read<GridCubit>().updateSpacing(state.gridSpacing + 5);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // **Button to Show Color Picker Circles**
                  ElevatedButton(
                    onPressed: () {
                      context.read<GridCubit>().toggleColorPicker();
                    },
                    child: const Text("Select Grid Color"),
                  ),

                  // **Color Picker Circles (only visible when button is clicked)**
                  if (state.showColorPicker)
                    Card(
                      margin: const EdgeInsets.only(top: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          children: [
                            ...[
                              Colors.grey,
                              Colors.blue,
                              Colors.red,
                              Colors.green,
                              Colors.orange,
                              Colors.purple,
                              Colors.brown,
                              Colors.cyan,
                              Colors.pink,
                              Colors.yellow,
                              Colors.teal,
                              Colors.black
                            ].map((color) {
                              return GestureDetector(
                                onTap: () {
                                  context.read<GridCubit>().updateColor(color);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 1.5),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
Positioned(
              top: 10,
              left: 20,
              child: Card(
                color: Colors.black.withOpacity(0.6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Zoom: ${(state.zoomLevel * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}




// class GridPainter extends CustomPainter {
//   final double gridSpacing;
//   final Color gridColor;

//   GridPainter({this.gridSpacing = 20.0, this.gridColor = Colors.grey});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = gridColor;

//     for (double x = 0; x < size.width; x += gridSpacing) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//     for (double y = 0; y < size.height; y += gridSpacing) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

/// Painter for the grid
/// /////////////////////////////////////////////////////////////////
// class GridPainter extends CustomPainter {
//   final double gridSpacing;
//   final Color gridColor;

//   GridPainter({required this.gridSpacing, required this.gridColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = gridColor
//       ..style = PaintingStyle.stroke;

//     for (double x = 0; x < size.width; x += gridSpacing) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//     for (double y = 0; y < size.height; y += gridSpacing) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }



/// Grid Painter
// class GridPainter extends CustomPainter {
//   final double gridSpacing;
//   final Color gridColor;

//   GridPainter({required this.gridSpacing, required this.gridColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = gridColor
//       ..style = PaintingStyle.stroke;

//     for (double x = 0; x < size.width; x += gridSpacing) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//     for (double y = 0; y < size.height; y += gridSpacing) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }



//for zoom

/// Grid Painter
class GridPainter extends CustomPainter {
  final double gridSpacing;
  final Color gridColor;

  GridPainter({required this.gridSpacing, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}