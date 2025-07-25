import 'dart:math';
import 'package:flutter/material.dart';

class PaintArc extends CustomPainter {
  final double start;
  final double sweep;
  final Color color;

  PaintArc({
    required this.start,
    required this.sweep,
    this.color = Colors.cyan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    paint1.strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: 50),
      start * pi / 16,
      sweep * pi / 16,
      false,
      paint1,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
