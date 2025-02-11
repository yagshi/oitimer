import 'package:flutter/material.dart';

class Digit5x7 extends CustomPainter {
  final number;
  final List<int> font = [0, 0];
  Digit5x7(this.number);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;
    canvas.drawOval(
        Rect.fromPoints(
            Offset(0, 0), Offset(size.width * 0.9, size.height * 0.9)),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
