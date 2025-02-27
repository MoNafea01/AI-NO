import 'package:ai_gen/node_package/data/vs_interface.dart';
import 'package:flutter/material.dart';

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

      final paint = Paint()..strokeWidth = 2.0;

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

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
