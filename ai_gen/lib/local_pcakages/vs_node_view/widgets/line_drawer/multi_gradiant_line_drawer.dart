import 'package:flutter/material.dart';

import '../../data/vs_interface.dart';

class MultiGradientLinePainter extends CustomPainter {
  ///Draws a line between all given interfaces
  MultiGradientLinePainter({
    required this.data,
  });

  final List<VSInputData> data;
  @override
  void paint(Canvas canvas, Size size) {
    for (var input in data) {
      if (input.widgetOffset == null ||
          input.nodeData?.widgetOffset == null ||
          input.connectedInterface?.widgetOffset == null ||
          input.connectedInterface?.nodeData?.widgetOffset == null) continue;

      final startPoint = input.widgetOffset! + input.nodeData!.widgetOffset;
      final endPoint = input.connectedInterface!.widgetOffset! +
          input.connectedInterface!.nodeData!.widgetOffset;

      final paint = Paint()
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      var colors = [
        input.connectedInterface?.interfaceColor ?? Colors.grey,
        input.interfaceColor,
      ];
      if (endPoint.dx <= 0) colors = colors.reversed.toList();

      final gradient = LinearGradient(
        colors: colors,
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromPoints(startPoint, endPoint));

      paint.shader = gradient;

      // Cubic Bézier curve
      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);

      late final Offset controlPoint1;
      late final Offset controlPoint2;
      if (endPoint.dx > startPoint.dx) {
        controlPoint1 = Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx) * -.8,
          startPoint.dy,
        );
        controlPoint2 = Offset(
          endPoint.dx + (endPoint.dx - startPoint.dx) * 0.8,
          endPoint.dy,
        );
      } else {
        controlPoint1 = Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx) * 0.6,
          startPoint.dy,
        );
        controlPoint2 = Offset(
          startPoint.dx + (endPoint.dx - startPoint.dx) * 0.4,
          endPoint.dy,
        );
      }

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        endPoint.dx,
        endPoint.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
