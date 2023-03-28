import 'dart:ui';
import 'package:flutter/material.dart';

///painter used to draw the arrow
class PointerPainter extends CustomPainter {
  final double animation;
  final Color arrowTintColor;
  final Color color;
  final double pointerHeight;
  PointerPainter({
    this.animation = 0.0,
    this.color = Colors.black,
    this.arrowTintColor = Colors.purple,
    this.pointerHeight = 100,
  });
  @override
  void paint(Canvas canvas, Size size) {
    // const pointerHeight = 100;
    final arrowHeight = pointerHeight / 5;

    var paint = Paint()..color = color;
    var startRadius = (size.height / 2) - (pointerHeight / 2);
    var mpath = Path();

    mpath.moveTo(0, startRadius);
    mpath.quadraticBezierTo(0, (startRadius) + (pointerHeight / 9),
        pointerHeight / 20, startRadius + (pointerHeight / 7));
    mpath.quadraticBezierTo(
        pointerHeight * 55 / 100,
        (size.height / 2),
        pointerHeight / 20,
        (startRadius + pointerHeight) - (pointerHeight / 7));
    mpath.quadraticBezierTo(
        0,
        (startRadius + pointerHeight) - (pointerHeight / 9),
        0,
        startRadius + pointerHeight);
    mpath.lineTo(0, size.height);
    var arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    var arrow = Path()
      ..moveTo(pointerHeight / 20, (size.height / 2) - arrowHeight)
      ..cubicTo(
          pointerHeight / 4,
          (size.height / 2) + (arrowHeight * 0.1),
          pointerHeight / 4,
          (size.height / 2) + (arrowHeight * 0.1),
          pointerHeight / 20,
          (size.height / 2) + arrowHeight)
      ..fillType = PathFillType.nonZero;
    canvas.drawShadow(mpath, Colors.black, 5.0, false);
    canvas.drawPath(mpath, paint);
    canvas.drawPath(arrow, arrowPaint);
    if (animation > 0) {
      var arrowPaint = Paint()
        ..color = arrowTintColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final path = createAnimatedPath(arrow, animation);
      canvas.drawPath(path, arrowPaint);
    }
  }

  Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;
    return extractPathUntilLength(originalPath, currentLength);
  }

  Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    var currentLength = 0.0;
    final path = Path();
    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;
      var nextLength = currentLength + metric.length;
      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);
        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }
      currentLength = nextLength;
    }

    return path;
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) {
    if (oldDelegate.animation == animation &&
        oldDelegate.arrowTintColor == arrowTintColor) {
      return false;
    }
    return true;
  }
}
