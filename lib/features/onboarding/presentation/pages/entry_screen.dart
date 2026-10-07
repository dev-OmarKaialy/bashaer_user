import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/motion_loop.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../../license/presentation/pages/license_gate_screen.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'free_trial_screen.dart';
import 'onboarding_screen.dart';

/// First frame after the bank sync: reads where this device left the funnel and
/// replaces itself with the step that comes next — the intro, the free trial, or
/// the license gate (active licenses go straight to home; pending can open Subscribe).
class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>()..loadSession(),
      child: const _EntryView(),
    );
  }
}

class _EntryView extends StatelessWidget {
  const _EntryView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status.isSuccess,
      listener: (context, state) => _route(context, state),
      child: const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(body: _EntryBody()),
      ),
    );
  }

  /// The funnel only moves forward, so each step replaces the whole stack: a
  /// student cannot swipe back into a finished step.
  static void _route(BuildContext context, OnboardingState state) {
    // A session that could not be read is treated as a fresh device rather than
    // a dead end — the worst case is showing the intro again.
    final session = state.session;
    final Widget next;
    if (session == null || !session.seen) {
      next = const OnboardingScreen();
    } else if (!session.trialCompleted) {
      next = const FreeTrialScreen();
    } else {
      // Returning users hit the license gate: active → home; otherwise pending
      // panel (Subscribe is optional from there, not forced every launch).
      next = const LicenseGateScreen();
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => next,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.animationNormal,
      ),
      (route) => false,
    );
  }
}

class _EntryBody extends StatelessWidget {
  const _EntryBody();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const SpeedLinesBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Entrance(
                    scale: true,
                    child: MotionLoop(
                      scale: 1.05,
                      duration: const Duration(milliseconds: 2800),
                      child: Container(
                        width: 96.r,
                        height: 96.r,
                        decoration: BoxDecoration(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.glowShadow(AppTheme.signalYellow, strength: 0.5),
                          border: Border.all(
                            color: AppTheme.onPrimaryColor.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(Assets.assetsIconsLauncherIcon, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Entrance(
                    index: 1,
                    child: Text(
                      'app.title'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.onPrimaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Entrance(
                    index: 2,
                    child: AppLottie(
                      asset: LottieAssets.driving,
                      size: 160.r,
                      semanticLabel: 'onboarding.preparing'.tr(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Entrance(
                    index: 3,
                    child: Text(
                      'onboarding.preparing'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
