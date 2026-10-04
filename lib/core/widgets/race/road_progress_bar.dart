import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';

/// A progress bar drawn as a road: asphalt track, dashed center lane, a
/// colored "driven" stretch and a car puck that drives to [progress].
/// Follows reading direction, so the car drives right-to-left in Arabic.
class RoadProgressBar extends StatelessWidget {
  const RoadProgressBar({
    super.key,
    required this.progress,
    this.gradient = AppTheme.sunsetGradient,
    this.height = 18,
    this.showCar = true,
  });

  /// Progress in the 0–1 range.
  final double progress;
  final LinearGradient gradient;
  final double height;
  final bool showCar;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final barHeight = height.h;
    final puck = barHeight * 1.9;
    return RepaintBoundary(
      child: SizedBox(
        height: showCar ? puck : barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress.clamp(0, 1).toDouble()),
              duration: reduceMotion ? Duration.zero : AppTheme.animationSlow,
              curve: AppTheme.slideCurve,
              builder: (context, value, _) {
                final travel = (width - puck).clamp(0, double.infinity) * value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(width: width, height: showCar ? puck : barHeight),
                    CustomPaint(
                      size: Size(width, barHeight),
                      painter: _RoadPainter(progress: value, gradient: gradient, isRtl: isRtl),
                    ),
                    if (showCar)
                      PositionedDirectional(
                        start: travel,
                        child: _CarPuck(size: puck, color: gradient.colors.last),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CarPuck extends StatelessWidget {
  const _CarPuck({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        boxShadow: AppTheme.glowShadow(color, strength: 0.4),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.directions_car_filled_rounded, color: color, size: size * 0.58),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  _RoadPainter({required this.progress, required this.gradient, required this.isRtl});

  final double progress;
  final LinearGradient gradient;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final road = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(road, Paint()..color = AppTheme.asphalt);

    final filledWidth = size.width * progress;
    if (filledWidth > 0) {
      final left = isRtl ? size.width - filledWidth : 0.0;
      final filledRect = Rect.fromLTWH(left, 0, filledWidth, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(filledRect, radius),
        Paint()
          ..shader = LinearGradient(
            colors: isRtl ? gradient.colors.reversed.toList() : gradient.colors,
          ).createShader(filledRect),
      );
    }

    // Dashed center lane
    final lane = Paint()
      ..color = AppTheme.laneWhite.withValues(alpha: 0.75)
      ..strokeWidth = size.height * 0.12
      ..strokeCap = StrokeCap.round;
    final dash = size.height * 0.9;
    final gap = size.height * 0.7;
    final y = size.height / 2;
    for (var x = size.height; x < size.width - size.height; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), lane);
    }
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.gradient != gradient ||
      oldDelegate.isRtl != isRtl;
}
