import 'package:flutter/material.dart';

class DashboardDashedBorder extends CustomPainter {
  const DashboardDashedBorder({
    required this.color,
    required this.radius,
    this.dash = 12,
    this.gap = 12,
  });
  final Color color;
  final double radius, dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += dash + gap) {
        canvas.drawPath(metric.extractPath(offset, offset + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashboardDashedBorder old) =>
      color != old.color ||
      radius != old.radius ||
      dash != old.dash ||
      gap != old.gap;
}
