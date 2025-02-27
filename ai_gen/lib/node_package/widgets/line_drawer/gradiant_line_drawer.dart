import 'package:flutter/material.dart';

class GradientLinePainter extends CustomPainter {
  ///Draws a line between 2 points with a gradient
  GradientLinePainter({
    this.startPoint,
    this.startColor,
    this.endPoint,
    this.endColor,
  });

  final Offset? startPoint;
  final Color? startColor;

  final Offset? endPoint;
  final Color? endColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (startPoint == null || endPoint == null) return;

    final paint = Paint()..strokeWidth = 2.0;

    var colors = [startColor ?? Colors.grey, endColor ?? Colors.grey];
    if (endPoint!.dx <= 0) colors = colors.reversed.toList();

    final gradient = LinearGradient(
      colors: colors,
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromPoints(startPoint!, endPoint!));

    paint.shader = gradient;

    canvas.drawLine(startPoint!, endPoint!, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
