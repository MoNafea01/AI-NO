import 'package:flutter/material.dart';

class TransparentSidesPainter extends CustomPainter {
  final bool transparentLeft;
  final bool transparentRight;
  final Color color;
  final double borderRadius;

  TransparentSidesPainter({
    required this.transparentLeft,
    required this.transparentRight,
    required this.color,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    print(size.width);
    // Clip for rounded corners
    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.clipRRect(roundedRect);

    paint.color = Colors.blue;
    double left = transparentLeft ? 10 : 0;
    double right = transparentRight ? 10 : 0;
    final rect = Rect.fromLTWH(left, 0, size.width - right, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
