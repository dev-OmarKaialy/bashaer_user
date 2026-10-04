import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';

/// Staggered fade + slide-up entrance. Respects the system "reduce motion"
/// setting and caps the stagger so long lists never wait on late items.
class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offsetY = 0.12,
    this.scale = false,
  });

  final Widget child;
  final int index;
  final double offsetY;
  final bool scale;

  static const int _maxStaggeredItems = 8;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final step = index.clamp(0, _maxStaggeredItems);
    var effects = child
        .animate(delay: AppTheme.staggerStep * step)
        .fadeIn(duration: AppTheme.animationNormal, curve: Curves.easeOut)
        .slideY(
          begin: offsetY,
          end: 0,
          duration: AppTheme.animationSlow,
          curve: AppTheme.slideCurve,
        );
    if (scale) {
      effects = effects.scaleXY(
        begin: 0.9,
        end: 1,
        duration: AppTheme.animationSlow,
        curve: AppTheme.springCurve,
      );
    }
    return effects;
  }
}
