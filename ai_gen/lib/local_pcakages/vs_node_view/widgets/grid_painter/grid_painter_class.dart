import 'package:flutter/material.dart';

class GridPainterClass extends CustomPainter {
  final double _gridSpacing;
  final Color _color;

  GridPainterClass({double? gridSpacing, Color? color})
      : _gridSpacing = gridSpacing ?? 30,
        _color = color ?? Colors.grey;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += _gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += _gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
