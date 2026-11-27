import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

// TODO(asset): Burst sticker vector drawn with CustomPainter since no SVG asset was exported in Referensi Design.
class BurstPainter extends CustomPainter {
  final Color fillColor;

  const BurstPainter({this.fillColor = SplashColors.magenta});

  static const List<Offset> _points = [
    Offset(0.50, 0.00),
    Offset(0.61, 0.16),
    Offset(0.78, 0.08),
    Offset(0.82, 0.26),
    Offset(0.98, 0.28),
    Offset(0.91, 0.45),
    Offset(1.00, 0.59),
    Offset(0.88, 0.70),
    Offset(0.89, 0.88),
    Offset(0.71, 0.88),
    Offset(0.62, 1.00),
    Offset(0.48, 0.91),
    Offset(0.35, 0.99),
    Offset(0.30, 0.84),
    Offset(0.13, 0.82),
    Offset(0.18, 0.65),
    Offset(0.04, 0.53),
    Offset(0.14, 0.39),
    Offset(0.06, 0.23),
    Offset(0.24, 0.22),
    Offset(0.26, 0.05),
    Offset(0.43, 0.13),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (int i = 0; i < _points.length; i++) {
      final point = Offset(_points[i].dx * size.width, _points[i].dy * size.height);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BurstPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor;
  }
}

class StickerStarWidget extends StatelessWidget {
  final String label;
  final double size;
  final Color color;

  const StickerStarWidget({
    super.key,
    this.label = '2026',
    this.size = 64,
    this.color = SplashColors.magenta,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: BurstPainter(fillColor: color),
          ),
          Text(
            label,
            style: SplashTypography.stickerStarText(fontSize: size * 0.24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
