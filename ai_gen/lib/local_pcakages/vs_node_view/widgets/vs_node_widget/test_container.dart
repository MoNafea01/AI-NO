import 'package:flutter/material.dart';

class TransparentRightContainerWithButton extends StatelessWidget {
  final double width;
  final double height;

  const TransparentRightContainerWithButton({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // You can place any child on top
        CustomPaint(
          size: Size(width, height),
          painter: _TransparentRightPainter(),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("data"),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Action"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransparentRightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Clip the container to rounded corners
    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(8),
    );
    canvas.clipRRect(roundedRect);

    // Draw the colored part (excluding the transparent right 20px)
    paint.color = Colors.blue;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width - 20, size.height),
      paint,
    );

    // Transparent part on the right is untouched
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
