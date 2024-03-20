import 'package:flutter/material.dart';

class RectanglePainter extends CustomPainter {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  Color? color;

  RectanglePainter(
      {required this.startX,
        required this.startY,
        required this.endX,
        required this.endY,
        this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromPoints(
      Offset(startX, startY),
      Offset(endX, endY),
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
