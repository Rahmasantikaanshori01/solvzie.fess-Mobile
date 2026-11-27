import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';

// TODO(asset): Fish vector illustration drawn with CustomPainter since no SVG asset was exported in Referensi Design.
class FishPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final Color eyeColor;
  final Color gillColor;

  const FishPainter({
    this.fillColor = SplashColors.orange,
    this.strokeColor = SplashColors.white,
    this.eyeColor = SplashColors.ink,
    this.gillColor = SplashColors.orangeDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Original viewBox is 0 0 72 42
    final double scaleX = size.width / 72.0;
    final double scaleY = size.height / 42.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Fish body path:
    // M52 8c8 1 15 7 18 13-3 7-10 12-18 13l-8-8c-8 8-22 9-34-5C22 7 36 8 44 16Z
    final bodyPath = Path()
      ..moveTo(52, 8)
      ..cubicTo(60, 9, 67, 15, 70, 21)
      ..cubicTo(67, 28, 60, 33, 52, 34)
      ..lineTo(44, 26)
      ..cubicTo(36, 34, 22, 35, 10, 21)
      ..cubicTo(22, 7, 36, 8, 44, 16)
      ..close();

    // Body fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, fillPaint);

    // Body stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bodyPath, strokePaint);

    // Eye: circle at (47, 18), r = 2.5
    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(47, 18), 2.5, eyePaint);

    // Eye highlight
    final eyeHighlightPaint = Paint()
      ..color = SplashColors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(47.7, 17.3), 0.9, eyeHighlightPaint);

    // Gill: M15 18c8 3 15 3 23 0
    final gillPath = Path()
      ..moveTo(15, 18)
      ..cubicTo(23, 21, 30, 21, 38, 18);

    final gillPaint = Paint()
      ..color = gillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(gillPath, gillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FishPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.eyeColor != eyeColor ||
        oldDelegate.gillColor != gillColor;
  }
}

class FishWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color fillColor;

  const FishWidget({
    super.key,
    this.width = 72,
    this.height = 42,
    this.fillColor = SplashColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: FishPainter(fillColor: fillColor),
    );
  }
}
