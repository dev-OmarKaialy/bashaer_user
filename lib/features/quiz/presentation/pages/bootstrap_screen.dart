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
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/road_progress_bar.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../../license/presentation/pages/license_gate_screen.dart';
import '../bloc/bootstrap_bloc.dart';
import '../bloc/bootstrap_event.dart';
import '../bloc/bootstrap_state.dart';

/// First frame after cold start: syncs the question bank, then opens home.
class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BootstrapBloc>()..add(const SyncBankEvent()),
      child: const _BootstrapView(),
    );
  }
}

class _BootstrapView extends StatelessWidget {
  const _BootstrapView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BootstrapBloc, BootstrapState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status.isSuccess,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const LicenseGateScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: AppTheme.animationNormal,
          ),
        );
      },
      child: const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(body: _BootstrapBody()),
      ),
    );
  }
}

class _BootstrapBody extends StatelessWidget {
  const _BootstrapBody();

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
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
              child: BlocSelector<BootstrapBloc, BootstrapState, RequestStatus>(
                selector: (state) => state.status,
                builder: (context, status) {
                  if (status.isFailed) {
                    return const _BootstrapError();
                  }
                  return const _BootstrapLoading();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const Entrance(child: _BrandMark()),
        SizedBox(height: 28.h),
        Entrance(
          index: 1,
          scale: true,
          child: AppLottie(
            asset: LottieAssets.driving,
            size: 220.r,
            semanticLabel: 'bootstrap.loading'.tr(),
          ),
        ),
        SizedBox(height: 12.h),
        Entrance(
          index: 2,
          child: Text(
            'bootstrap.loading'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.onPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Entrance(
          index: 3,
          child: Text(
            'bootstrap.subtitle'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onPrimaryColor.withValues(alpha: 0.78),
            ),
          ),
        ),
        SizedBox(height: 28.h),
        Entrance(
          index: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: const _SyncProgress(),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        const Entrance(child: _BrandMark()),
        SizedBox(height: 24.h),
        Entrance(
          index: 1,
          child: Icon(Icons.cloud_off_rounded, size: 72.r, color: AppTheme.onPrimaryColor),
        ),
        SizedBox(height: 16.h),
        Entrance(
          index: 2,
          child: Text(
            'bootstrap.errorTitle'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.onPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Entrance(
          index: 3,
          child: Text(
            'bootstrap.errorBody'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.8)),
          ),
        ),
        SizedBox(height: 28.h),
        Entrance(
          index: 4,
          child: RaceButton(
            label: 'bootstrap.retry'.tr(),
            icon: Icons.refresh_rounded,
            gradient: AppTheme.sunsetGradient,
            shine: true,
            onPressed: () => context.read<BootstrapBloc>().add(const SyncBankEvent()),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88.r,
          height: 88.r,
          decoration: BoxDecoration(
            color: AppTheme.onPrimaryColor.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow(AppTheme.signalYellow, strength: 0.55),
            border: Border.all(color: AppTheme.onPrimaryColor.withValues(alpha: 0.35), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/icons/launcher_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.directions_car_filled_rounded,
              size: 44.r,
              color: AppTheme.onPrimaryColor,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'app.title'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onPrimaryColor,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'app.tagline'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

/// Determinate road bar: the car drives from 0 to 100% as the sync reports in.
class _SyncProgress extends StatelessWidget {
  const _SyncProgress();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BootstrapBloc, BootstrapState, double>(
      selector: (state) => state.progress,
      builder: (context, progress) {
        return Column(
          children: [
            RoadProgressBar(progress: progress, gradient: AppTheme.goldGradient, height: 14),
            SizedBox(height: 10.h),
            _ProgressPercent(progress: progress),
          ],
        );
      },
    );
  }
}

class _ProgressPercent extends StatelessWidget {
  const _ProgressPercent({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round().clamp(0, 100);
    return Text(
      '$percent%',
      textDirection: TextDirection.ltr,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontFamily: AppTheme.displayNumberFont,
        fontWeight: FontWeight.w700,
        color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
        letterSpacing: 1.2,
      ),
    );
  }
}
