import 'package:flutter/material.dart';

/// A custom painter that draws a gradient line between two points.
///
/// This painter is used to draw connection lines between nodes in the visual
/// scripting interface. It supports:
/// - Gradient coloring between start and end points
/// - Automatic color reversal based on line direction
/// - Customizable line width and colors
class GradientLinePainter extends CustomPainter {
  /// Creates a new [GradientLinePainter] instance.
  ///
  /// [startPoint] is the starting point of the line.
  /// [startColor] is the color at the starting point.
  /// [endPoint] is the ending point of the line.
  /// [endColor] is the color at the ending point.
  const GradientLinePainter({
    this.startPoint,
    this.startColor,
    this.endPoint,
    this.endColor,
  });

  /// The starting point of the line
  final Offset? startPoint;

  /// The color at the starting point
  final Color? startColor;

  /// The ending point of the line
  final Offset? endPoint;

  /// The color at the ending point
  final Color? endColor;

  /// The default color used when no color is specified
  static const Color _defaultColor = Colors.grey;

  /// The width of the line in logical pixels
  static const double _lineWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (!_canDrawLine()) return;

    final paint = _createPaint();
    canvas.drawLine(startPoint!, endPoint!, paint);
  }

  /// Determines if the line can be drawn
  bool _canDrawLine() {
    return startPoint != null && endPoint != null;
  }

  /// Creates the paint object for drawing the line
  Paint _createPaint() {
    final paint = Paint()..strokeWidth = _lineWidth;
    paint.shader = _createGradientShader();
    return paint;
  }

  /// Creates the gradient shader for the line
  Shader _createGradientShader() {
    final colors = _getGradientColors();
    return LinearGradient(
      colors: colors,
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromPoints(startPoint!, endPoint!));
  }

  /// Gets the colors for the gradient, handling direction-based reversal
  List<Color> _getGradientColors() {
    final colors = [
      startColor ?? _defaultColor,
      endColor ?? _defaultColor,
    ];

    // Reverse colors if the line goes from right to left
    if (endPoint!.dx <= 0) {
      return colors.reversed.toList();
    }

    return colors;
  }

  @override
  bool shouldRepaint(covariant GradientLinePainter oldDelegate) {
    return startPoint != oldDelegate.startPoint ||
        endPoint != oldDelegate.endPoint ||
        startColor != oldDelegate.startColor ||
        endColor != oldDelegate.endColor;
  }
}
