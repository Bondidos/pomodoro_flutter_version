import 'dart:math';

import 'package:flutter/material.dart';

class FillingCircle extends CustomPainter {
  final double _periodMs;
  final double _currentMs;
  BuildContext context;

  FillingCircle({
    required this.context,
    required double periodMs,
    required double currentMs,
  })  : _periodMs = periodMs,
        _currentMs = currentMs;

  @override
  void paint(Canvas canvas, Size size) {
    Paint painter = Paint()
      ..color = Theme.of(context).primaryColor
      ..style = PaintingStyle.fill;

    Offset _center = Offset(size.width / 2, size.height / 2);
    double startAngle =
    (((_currentMs % _periodMs).toDouble() / _periodMs) * (360 * pi / 180));
    canvas.drawArc(
      Rect.fromCircle(radius: 20, center: _center),
      -1.5708,
      startAngle,
      true,
      painter,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}