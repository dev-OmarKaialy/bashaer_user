import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_state.dart';

/// Streak lengths worth a celebration: 3, 5, 10, then every 5.
bool isStreakMilestone(int streak) =>
    streak == 3 || streak == 5 || (streak >= 10 && streak % 5 == 0);

/// Transparent layer over the quiz that bursts confetti and a "🔥 N in a row"
/// banner (plus a haptic) when the streak reaches a milestone. Never takes
/// touches. The sound is played by the quiz's answer feedback.
class StreakCelebrationLayer extends StatefulWidget {
  const StreakCelebrationLayer({super.key});

  @override
  State<StreakCelebrationLayer> createState() => _StreakCelebrationLayerState();
}

class _StreakCelebrationLayerState extends State<StreakCelebrationLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  /// The milestone being celebrated; also keys the confetti so it replays.
  int _streak = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _celebrate(BuildContext context, QuizState state) {
    HapticFeedback.heavyImpact();
    if (MediaQuery.disableAnimationsOf(context)) return;
    // No setState: the AnimatedBuilder below rebuilds on every tick.
    _streak = state.streak;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listenWhen: (prev, curr) =>
          prev.attemptSerial != curr.attemptSerial &&
          curr.streak > prev.streak &&
          isStreakMilestone(curr.streak),
      listener: _celebrate,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (!_controller.isAnimating) return const SizedBox.shrink();
            return Stack(
              children: [
                Positioned.fill(
                  child: AppLottie(
                    key: ValueKey(_streak),
                    asset: _streak >= 10 ? LottieAssets.confetti : LottieAssets.sparkle,
                    repeat: false,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.35),
                  child: _StreakBanner(streak: _streak, progress: _controller.value),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The pill that springs in, holds, then fades and floats away.
class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak, required this.progress});

  final int streak;

  /// 0–1 through the celebration.
  final double progress;

  String get _cheerKey {
    if (streak >= 10) return 'streak.legend';
    if (streak >= 5) return 'streak.blazing';
    return 'streak.hot';
  }

  @override
  Widget build(BuildContext context) {
    final springIn = AppTheme.bounceCurve.transform((progress / 0.35).clamp(0.0, 1.0));
    final fadeOut = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
    final textTheme = Theme.of(context).textTheme;
    return Transform.translate(
      offset: Offset(0, -30.h * fadeOut),
      child: Transform.scale(
        scale: 0.4 + 0.6 * springIn,
        child: Opacity(
          opacity: 1 - fadeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: streak >= 10 ? AppTheme.candyGradient : AppTheme.sunsetGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusXL.r),
              boxShadow: AppTheme.glowShadow(AppTheme.racingRed),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🔥 ${'streak.inARow'.tr(namedArgs: {'count': '$streak'})}',
                    style: textTheme.headlineSmall?.copyWith(color: AppTheme.onPrimaryColor),
                  ),
                  Text(
                    _cheerKey.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
