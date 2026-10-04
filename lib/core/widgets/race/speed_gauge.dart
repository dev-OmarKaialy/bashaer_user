import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_theme.dart';

/// Speedometer-style gauge for a 0–100 value. The arc sweeps and the needle
/// swings up to [value] on first build and whenever [value] changes.
class SpeedGauge extends StatelessWidget {
  const SpeedGauge({
    super.key,
    required this.value,
    required this.label,
    this.size = 180,
    this.onDark = false,
    this.suffix = '%',
  });

  /// Value in the 0–100 range.
  final double value;
  final String label;
  final double size;
  final bool onDark;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0, 100).toDouble();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final textColor = onDark ? AppTheme.onPrimaryColor : AppTheme.ink;
    return Semantics(
      label: '$label ${target.round()}$suffix',
      child: RepaintBoundary(
        child: SizedBox(
          width: size.r,
          height: size.r * 0.86,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: reduceMotion ? Duration.zero : AppTheme.animationGauge,
            curve: Curves.easeOutCubic,
            builder: (context, animated, _) {
              return CustomPaint(
                painter: _GaugePainter(value: animated, onDark: onDark),
                child: Align(
                  alignment: const Alignment(0, 0.5),
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${animated.round()}$suffix',
                          style: AppTheme.numberStyle(size.r * 0.2, color: textColor),
                        ),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: onDark
                                ? AppTheme.onPrimaryColor.withValues(alpha: 0.85)
                                : AppTheme.inkSoft,
                            fontSize: (size * 0.07).sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value, required this.onDark});

  final double value;
  final bool onDark;

  static const double _startAngle = math.pi * 0.75; // 135°
  static const double _sweepAngle = math.pi * 1.5; // 270°

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, radius);
    final stroke = radius * 0.14;
    final arcRect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = onDark ? AppTheme.onPrimaryColor.withValues(alpha: 0.18) : AppTheme.mutedSurface;
    canvas.drawArc(arcRect, _startAngle, _sweepAngle, false, track);

    final fraction = value / 100;
    if (fraction > 0) {
      final progress = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: _sweepAngle,
          colors: [
            AppTheme.racingRed,
            AppTheme.turboOrange,
            AppTheme.signalYellow,
            AppTheme.mintGreen,
          ],
          stops: [0, 0.4, 0.65, 1],
          transform: GradientRotation(_startAngle),
        ).createShader(arcRect);
      canvas.drawArc(arcRect, _startAngle, _sweepAngle * fraction, false, progress);
    }

    // Tick marks
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = onDark ? AppTheme.onPrimaryColor.withValues(alpha: 0.6) : AppTheme.inkFaint;
    const ticks = 10;
    for (var i = 0; i <= ticks; i++) {
      final angle = _startAngle + _sweepAngle * (i / ticks);
      final isMajor = i.isEven;
      final outer = radius - stroke * 1.35;
      final inner = outer - (isMajor ? stroke * 0.8 : stroke * 0.45);
      tickPaint.strokeWidth = isMajor ? 2.4 : 1.4;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        tickPaint,
      );
    }

    // Needle
    final needleAngle = _startAngle + _sweepAngle * fraction;
    final needleLength = radius - stroke * 2.6;
    final needleColor = onDark ? AppTheme.onPrimaryColor : AppTheme.ink;
    final direction = Offset(math.cos(needleAngle), math.sin(needleAngle));
    final normal = Offset(-direction.dy, direction.dx);
    final baseWidth = radius * 0.05;
    final needle = Path()
      ..moveTo(center.dx + normal.dx * baseWidth, center.dy + normal.dy * baseWidth)
      ..lineTo(center.dx + direction.dx * needleLength, center.dy + direction.dy * needleLength)
      ..lineTo(center.dx - normal.dx * baseWidth, center.dy - normal.dy * baseWidth)
      ..close();
    canvas.drawPath(needle, Paint()..color = needleColor.withValues(alpha: 0.9));
    canvas.drawCircle(center, radius * 0.08, Paint()..color = AppTheme.racingRed);
    canvas.drawCircle(center, radius * 0.035, Paint()..color = AppTheme.onPrimaryColor);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.onDark != onDark;
}
