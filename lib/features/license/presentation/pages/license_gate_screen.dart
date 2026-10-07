import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/motion_loop.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../../quiz/presentation/pages/home_screen.dart';
import '../../../subscription/presentation/pages/subscribe_screen.dart';
import '../../data/models/license_error_codes.dart';
import '../cubit/license_cubit.dart';
import '../cubit/license_state.dart';

/// Validates license by device id, then opens home. Unlicensed devices can
/// open Subscribe or restart the intro + free trial.
class LicenseGateScreen extends StatelessWidget {
  const LicenseGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LicenseCubit>()..checkSession(),
      child: const _LicenseGateView(),
    );
  }
}

class _LicenseGateView extends StatelessWidget {
  const _LicenseGateView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LicenseCubit, LicenseState>(
      listenWhen: (previous, current) =>
          previous.phase != current.phase && current.phase == LicensePhase.active,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: AppTheme.animationNormal,
          ),
        );
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const SpeedLinesBackground(),
                SafeArea(
                  child: BlocBuilder<LicenseCubit, LicenseState>(
                    buildWhen: (prev, curr) =>
                        prev.phase != curr.phase ||
                        prev.checkStatus != curr.checkStatus ||
                        prev.errorCode != curr.errorCode ||
                        prev.deviceId != curr.deviceId,
                    builder: (context, state) {
                      if (state.phase == LicensePhase.checking ||
                          state.phase == LicensePhase.active) {
                        return RaceLoader(label: 'license.checking'.tr());
                      }
                      return const PendingLicensePanel();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PendingLicensePanel extends StatelessWidget {
  const PendingLicensePanel({super.key});

  Future<void> _restartIntroAndTrial(BuildContext context) async {
    final cubit = getIt<OnboardingCubit>();
    await cubit.resetFunnel();
    if (!context.mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseCubit, LicenseState>(
      buildWhen: (prev, curr) =>
          prev.checkStatus != curr.checkStatus ||
          prev.errorCode != curr.errorCode ||
          prev.deviceId != curr.deviceId,
      builder: (context, state) {
        final loading = state.checkStatus.isLoading;
        final deviceId = state.deviceId ?? '—';
        final errorKey = state.checkStatus.isFailed
            ? licenseErrorMessageKey(state.errorCode)
            : null;
        final isPending =
            state.errorCode == LicenseErrorCodes.pending ||
            state.errorCode == LicenseErrorCodes.invalid;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Entrance(
                scale: true,
                child: Center(
                  child: MotionLoop(
                    scale: 1.06,
                    duration: const Duration(milliseconds: 3000),
                    child: AppLottie(
                      asset: LottieAssets.premium,
                      size: 120.r,
                      semanticLabel: 'license.title'.tr(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Entrance(
                index: 1,
                child: Text(
                  'license.title'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.onPrimaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Entrance(
                index: 2,
                child: Text(
                  isPending ? 'license.subtitlePending'.tr() : 'license.subtitleBlocked'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onPrimaryColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Entrance(
                index: 3,
                child: RaceCard(
                  padding: EdgeInsets.all(16.r),
                  borderColor: AppTheme.signalYellow.withValues(alpha: 0.28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'license.deviceIdLabel'.tr(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      SizedBox(height: 8.h),
                      SelectableText(
                        deviceId,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      RaceButton(
                        label: 'license.copyDeviceId'.tr(),
                        icon: Icons.copy_rounded,
                        gradient: AppTheme.sunsetGradient,
                        shine: true,
                        fullWidth: true,
                        onPressed: loading
                            ? null
                            : () async {
                                await Clipboard.setData(ClipboardData(text: deviceId));
                                Toaster.showToast('license.copied'.tr(), isError: false);
                              },
                      ),
                      if (errorKey != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          errorKey.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isPending ? AppTheme.inkFaint : AppTheme.dangerColor,
                          ),
                        ),
                      ],
                      SizedBox(height: 18.h),
                      RaceButton(
                        label: loading ? 'license.checking'.tr() : 'license.retry'.tr(),
                        icon: Icons.refresh_rounded,
                        fullWidth: true,
                        onPressed: loading
                            ? null
                            : () => context.read<LicenseCubit>().checkSession(),
                      ),
                      SizedBox(height: 10.h),
                      RaceButton(
                        label: 'license.openSubscribe'.tr(),
                        icon: Icons.workspace_premium_rounded,
                        gradient: AppTheme.limeGradient,
                        fullWidth: true,
                        onPressed: loading
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => const SubscribeScreen()),
                              ),
                      ),
                      SizedBox(height: 10.h),
                      RaceButton(
                        label: 'license.restartTrial'.tr(),
                        icon: Icons.replay_rounded,
                        variant: RaceButtonVariant.outline,
                        gradient: AppTheme.grapeGradient,
                        fullWidth: true,
                        onPressed: loading ? null : () => _restartIntroAndTrial(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
