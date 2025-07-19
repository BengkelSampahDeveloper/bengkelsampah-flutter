import 'dart:math' as math;
import 'package:flutter/material.dart';

class HalfCircleUp extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const HalfCircleUp({
    super.key,
    this.width = 200,
    this.height = 100,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _HalfCircleUpPainter(color),
    );
  }
}

class _HalfCircleUpPainter extends CustomPainter {
  final Color color;

  _HalfCircleUpPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(
      rect,
      math.pi, // mulai dari atas
      math.pi, // sapuan setengah lingkaran
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
