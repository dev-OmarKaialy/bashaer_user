import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../../quiz/presentation/pages/home_screen.dart';
import '../../data/models/license_error_codes.dart';
import '../cubit/license_cubit.dart';
import '../cubit/license_state.dart';

/// After bank sync: validates license by device id, then opens home.
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.h),
              Entrance(
                child: Icon(
                  Icons.phonelink_lock_rounded,
                  size: 64.r,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
              SizedBox(height: 16.h),
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
              SizedBox(height: 28.h),
              Entrance(
                index: 3,
                child: RaceCard(
                  padding: EdgeInsets.all(16.r),
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
                        onPressed: loading
                            ? null
                            : () => context.read<LicenseCubit>().checkSession(),
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
