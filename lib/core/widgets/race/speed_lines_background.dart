import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Animated "speed lines" and lane dashes streaming across a hero surface.
/// Paints through the animation (no widget rebuilds), sits in its own
/// repaint boundary, and freezes when the system asks to reduce motion.
class SpeedLinesBackground extends StatefulWidget {
  const SpeedLinesBackground({super.key, this.color = AppTheme.onPrimaryColor});

  final Color color;

  @override
  State<SpeedLinesBackground> createState() => _SpeedLinesBackgroundState();
}

class _SpeedLinesBackgroundState extends State<SpeedLinesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SpeedLinesPainter(animation: _controller, color: widget.color, isRtl: isRtl),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  _SpeedLinesPainter({required this.animation, required this.color, required this.isRtl})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final bool isRtl;

  // (vertical position, length factor, speed factor, opacity)
  static const List<(double, double, double, double)> _lines = [
    (0.14, 0.30, 1.0, 0.20),
    (0.27, 0.18, 1.6, 0.14),
    (0.41, 0.36, 0.8, 0.12),
    (0.58, 0.22, 1.3, 0.18),
    (0.72, 0.40, 1.1, 0.10),
    (0.86, 0.16, 1.9, 0.16),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (final (y, length, speed, opacity) in _lines) {
      final lineLength = size.width * length;
      final travel = size.width + lineLength;
      final t = (animation.value * speed) % 1.0;
      // Lines stream against the reading direction, like scenery passing by.
      final start = isRtl ? -lineLength + travel * t : size.width - travel * t;
      paint
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = size.height * 0.012 + 1.5;
      canvas.drawLine(
        Offset(start, size.height * y),
        Offset(start + lineLength, size.height * y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedLinesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isRtl != isRtl;
}
