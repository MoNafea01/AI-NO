import 'package:flutter/material.dart';

import 'grid_painter_class.dart';

class GridPainter extends StatelessWidget {
  const GridPainter({
    super.key,
    required this.width,
    required this.height,
    this.color,
    this.spacing,
  });

  final double width;
  final double height;

  final Color? color;
  final double? spacing;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: GridPainterClass(color: color, gridSpacing: spacing),
    );
  }
}
