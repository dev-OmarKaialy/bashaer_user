import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/motion_loop.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../../license/presentation/pages/license_gate_screen.dart';
import '../../../quiz/presentation/bloc/quiz_event.dart';
import '../../../quiz/presentation/pages/quiz_screen.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// The free trial: loads the first questions of the bank and runs them as a
/// practice session that cannot be closed half way. Finishing it opens the
/// license gate.
class FreeTrialScreen extends StatelessWidget {
  const FreeTrialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>()..loadTrialQuestions(),
      child: const _FreeTrialView(),
    );
  }
}

class _FreeTrialView extends StatelessWidget {
  const _FreeTrialView();

  /// Runs the trial questions, then hands off to the license gate. Subscribe is
  /// no longer after the trial — returning users see it from Entry instead.
  Future<void> _onFinished(BuildContext context) async {
    await context.read<OnboardingCubit>().completeFreeTrial();
    if (!context.mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LicenseGateScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) =>
          previous.trialStatus != current.trialStatus ||
          previous.trialQuestions != current.trialQuestions,
      builder: (context, state) {
        if (state.trialStatus.isLoading || state.trialStatus.isInit) {
          return const _TrialScaffold(child: _TrialLoading());
        }

        if (state.trialStatus.isFailed || state.trialQuestions.isEmpty) {
          return _TrialScaffold(
            child: _TrialError(
              onRetry: () => context.read<OnboardingCubit>().loadTrialQuestions(),
              onSkip: () => _onFinished(context),
            ),
          );
        }

        return QuizScreen(
          questions: state.trialQuestions,
          mode: QuizMode.practice,
          title: 'trial.title'.tr(),
          allowExit: false,
          onFinished: () => _onFinished(context),
          finishLabel: 'trial.finish'.tr(),
          finishIcon: Icons.verified_rounded,
        );
      },
    );
  }
}

class _TrialScaffold extends StatelessWidget {
  const _TrialScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const SpeedLinesBackground(),
              SafeArea(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrialLoading extends StatelessWidget {
  const _TrialLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Entrance(
            scale: true,
            child: MotionLoop(
              offset: Offset(0, 8.h),
              scale: 1.04,
              duration: const Duration(milliseconds: 2800),
              child: AppLottie(
                asset: LottieAssets.medal,
                size: 180.r,
                semanticLabel: 'trial.loading'.tr(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Entrance(
            index: 1,
            child: Text(
              'trial.title'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.onPrimaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Entrance(
            index: 2,
            child: Text(
              'trial.loading'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onPrimaryColor.withValues(alpha: 0.82),
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _TrialError extends StatelessWidget {
  const _TrialError({required this.onRetry, required this.onSkip});

  final VoidCallback onRetry;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Entrance(
            scale: true,
            child: AppLottie(
              asset: LottieAssets.fail,
              size: 140.r,
              semanticLabel: 'trial.error'.tr(),
            ),
          ),
          SizedBox(height: 16.h),
          Entrance(
            index: 1,
            child: Text(
              'trial.error'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.onPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Entrance(
            index: 2,
            child: RaceButton(
              label: 'trial.retry'.tr(),
              icon: Icons.refresh_rounded,
              gradient: AppTheme.sunsetGradient,
              shine: true,
              fullWidth: true,
              onPressed: onRetry,
            ),
          ),
          SizedBox(height: 10.h),
          Entrance(
            index: 3,
            child: RaceButton(
              label: 'trial.skip'.tr(),
              icon: Icons.arrow_forward_rounded,
              variant: RaceButtonVariant.outline,
              gradient: AppTheme.grapeGradient,
              fullWidth: true,
              onPressed: onSkip,
            ),
          ),
        ],
      ),
    );
  }
}
