import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

/// Flame chip with the current run of correct answers. Pops on every
/// increase, heats up as the run grows, and shakes when a run of 2+ breaks.
class StreakBadge extends StatefulWidget {
  const StreakBadge({super.key, required this.streak});

  final int streak;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge> with TickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: AppTheme.animationNormal,
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(covariant StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (MediaQuery.disableAnimationsOf(context)) return;
    if (widget.streak > oldWidget.streak) {
      _pop.forward(from: 0);
    } else if (widget.streak == 0 && oldWidget.streak >= 2) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _shake.dispose();
    super.dispose();
  }

  static Color _colorFor(int streak) {
    if (streak >= 10) return AppTheme.hotPink;
    if (streak >= 5) return AppTheme.racingRed;
    if (streak >= 1) return AppTheme.turboOrange;
    return AppTheme.inkFaint;
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.streak;
    final color = _colorFor(streak);
    final chip = Semantics(
      label: 'streak.semantic'.tr(namedArgs: {'count': '$streak'}),
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppTheme.animationNormal,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: streak >= 5 ? AppTheme.glowShadow(color, strength: 0.35) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, size: 16.r, color: color),
            SizedBox(width: 2.w),
            Text('$streak', style: AppTheme.numberStyle(14.sp, color: color)),
          ],
        ),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_pop, _shake]),
      child: chip,
      builder: (context, child) {
        final scale = 1 + 0.35 * math.sin(math.pi * _pop.value);
        final dx = math.sin(_shake.value * math.pi * 6) * 6 * (1 - _shake.value);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

/// Wraps the points tag: whenever [points] changes, a "+N" / "−N" rises from
/// it and fades out.
class ScoreFloat extends StatefulWidget {
  const ScoreFloat({super.key, required this.points, required this.child});

  final int points;
  final Widget child;

  @override
  State<ScoreFloat> createState() => _ScoreFloatState();
}

class _ScoreFloatState extends State<ScoreFloat> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  int _delta = 0;

  @override
  void didUpdateWidget(covariant ScoreFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    final delta = widget.points - oldWidget.points;
    if (delta == 0 || MediaQuery.disableAnimationsOf(context)) return;
    _delta = delta;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (!_controller.isAnimating) return const SizedBox.shrink();
                final t = Curves.easeOut.transform(_controller.value);
                final gained = _delta > 0;
                return Transform.translate(
                  offset: Offset(0, -26.h * t),
                  child: Opacity(
                    opacity: 1 - t,
                    child: Center(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          gained ? '+$_delta' : '−${-_delta}',
                          style: AppTheme.numberStyle(
                            16.sp,
                            color: gained ? AppTheme.successColor : AppTheme.dangerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
