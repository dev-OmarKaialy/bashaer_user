import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Odometer-style number that counts up to [value].
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({super.key, required this.value, required this.style, this.suffix = ''});

  final num value;
  final TextStyle style;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: reduceMotion ? Duration.zero : AppTheme.animationGauge,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text('${animated.round()}$suffix', style: style),
    );
  }
}
