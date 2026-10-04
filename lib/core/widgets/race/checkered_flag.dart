import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A strip of checkered-flag squares, used on finish-line moments.
class CheckeredStrip extends StatelessWidget {
  const CheckeredStrip({
    super.key,
    this.rows = 2,
    this.squareSize = 8,
    this.color = AppTheme.ink,
    this.opacity = 1,
  });

  final int rows;
  final double squareSize;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(double.infinity, rows * squareSize),
        painter: _CheckeredPainter(
          rows: rows,
          square: squareSize,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _CheckeredPainter extends CustomPainter {
  _CheckeredPainter({required this.rows, required this.square, required this.color});

  final int rows;
  final double square;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final columns = (size.width / square).ceil();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        if ((r + c).isEven) {
          canvas.drawRect(Rect.fromLTWH(c * square, r * square, square, square), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckeredPainter oldDelegate) =>
      oldDelegate.rows != rows || oldDelegate.square != square || oldDelegate.color != color;
}
