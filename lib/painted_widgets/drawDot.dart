import 'package:flutter/material.dart';

class DotPainter extends CustomPainter {
  BuildContext context;

  DotPainter({
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..color = Theme.of(context).primaryColor
      ..style = PaintingStyle.fill;
    double _radius = 8.0;
    Offset _center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(_center, _radius, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}