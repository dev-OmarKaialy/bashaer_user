import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
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
import '../../../../core/widgets/race/checkered_flag.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/motion_loop.dart';
import '../../../../core/widgets/race/pressable.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'free_trial_screen.dart';

/// What the app does, one slide at a time, with a single call to action: start
/// the free trial. The slides are static content; only the CTA has behaviour.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The provider lives above the flow, so everything inside it — the CTA
    // included — reads the same instance through `context.read`.
    return BlocProvider(create: (_) => getIt<OnboardingCubit>(), child: const _OnboardingFlow());
  }
}

class _OnboardingFlow extends StatefulWidget {
  const _OnboardingFlow();

  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow> {
  final PageController _pages = PageController();
  final ValueNotifier<int> _page = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pages.dispose();
    _page.dispose();
    super.dispose();
  }

  Future<void> _startTrial() async {
    final cubit = context.read<OnboardingCubit>();
    await cubit.startFreeTrial();
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const FreeTrialScreen()),
      (route) => false,
    );
  }

  void _goTo(int index) {
    _pages.animateToPage(index, duration: AppTheme.animationNormal, curve: AppTheme.slideCurve);
  }

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
              SafeArea(
                child: Column(
                  children: [
                    const _OnboardingHeader(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pages,
                        itemCount: _slides.length,
                        onPageChanged: (index) => _page.value = index,
                        itemBuilder: (context, index) =>
                            _Slide(index: index, slide: _slides[index]),
                      ),
                    ),
                    _StepFooter(page: _page, count: _slides.length, onSelect: _goTo),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 22.h),
                      child: BlocSelector<OnboardingCubit, OnboardingState, bool>(
                        selector: (state) => state.status.isLoading,
                        builder: (context, isSaving) => RaceButton(
                          label: 'onboarding.startTrial'.tr(),
                          icon: Icons.play_circle_fill_rounded,
                          gradient: AppTheme.sunsetGradient,
                          shine: true,
                          fullWidth: true,
                          loading: isSaving,
                          onPressed: isSaving ? null : _startTrial,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The benefit slides, in the order they are shown. [chip] is the secondary
/// icon that floats beside the illustration.
const List<({IconData icon, IconData chip, String lottie, String title, String body})> _slides = [
  (
    icon: Icons.menu_book_rounded,
    chip: Icons.verified_rounded,
    lottie: LottieAssets.driving,
    title: 'onboarding.slide1Title',
    body: 'onboarding.slide1Body',
  ),
  (
    icon: Icons.bolt_rounded,
    chip: Icons.check_circle_rounded,
    lottie: LottieAssets.correct,
    title: 'onboarding.slide2Title',
    body: 'onboarding.slide2Body',
  ),
  (
    icon: Icons.insights_rounded,
    chip: Icons.emoji_events_rounded,
    lottie: LottieAssets.trophy,
    title: 'onboarding.slide3Title',
    body: 'onboarding.slide3Body',
  ),
  (
    icon: Icons.wifi_off_rounded,
    chip: Icons.download_done_rounded,
    lottie: LottieAssets.medal,
    title: 'onboarding.slide4Title',
    body: 'onboarding.slide4Body',
  ),
];

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 4.h),
      child: Row(
        children: [
          MotionLoop(
            offset: Offset(0, -6.h),
            scale: 1.04,
            duration: const Duration(milliseconds: 2800),
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: AppTheme.onPrimaryColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.onPrimaryColor.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(Assets.assetsIconsLauncherIcon, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'app.title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.onPrimaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'onboarding.freeTrialBadge'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.signalYellow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.index, required this.slide});

  final int index;
  final ({IconData icon, IconData chip, String lottie, String title, String body}) slide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Entrance(
            index: 0,
            scale: true,
            child: _SlideIllustration(index: index, slide: slide),
          ),
          SizedBox(height: 14.h),
          Entrance(
            index: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaceTag(
                  label: 'onboarding.stepOf'.tr(
                    namedArgs: {'current': '${index + 1}', 'total': '${_slides.length}'},
                  ),
                  color: AppTheme.signalYellow,
                  icon: Icons.flag_rounded,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Entrance(
            index: 2,
            child: Text(
              slide.title.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.onPrimaryColor,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Entrance(
            index: 3,
            child: Text(
              slide.body.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onPrimaryColor.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The illustration for one slide: the Lottie in a glowing gradient card, a
/// soft halo behind it, two floating icon badges and a finish-line strip.
class _SlideIllustration extends StatelessWidget {
  const _SlideIllustration({required this.index, required this.slide});

  final int index;
  final ({IconData icon, IconData chip, String lottie, String title, String body}) slide;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentGradientAt(index);
    final accentColor = accent.colors.first;
    return SizedBox(
      height: 250.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Halo that breathes behind the card.
          Center(
            child: MotionLoop(
              scale: 1.08,
              duration: const Duration(milliseconds: 3400),
              child: Container(
                width: 224.r,
                height: 224.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accentColor.withValues(alpha: 0.42), accentColor.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: MotionLoop(
              offset: Offset(0, 8.h),
              duration: const Duration(milliseconds: 3000),
              child: RaceCard(
                gradient: accent,
                glowColor: accentColor,
                radius: AppTheme.radiusXXL,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
                child: AppLottie(asset: slide.lottie, size: 140.r, semanticLabel: slide.title.tr()),
              ),
            ),
          ),
          PositionedDirectional(
            start: 6.w,
            top: 18.h,
            child: MotionLoop(
              offset: Offset(0, -12.h),
              scale: 1.05,
              duration: const Duration(milliseconds: 2400),
              child: GradientIconBadge(gradient: AppTheme.goldGradient, icon: slide.icon, size: 46),
            ),
          ),
          PositionedDirectional(
            end: 4.w,
            bottom: 40.h,
            child: MotionLoop(
              offset: Offset(0, 12.h),
              scale: 1.05,
              duration: const Duration(milliseconds: 2700),
              child: GradientIconBadge(
                gradient: AppTheme.candyGradient,
                icon: slide.chip,
                size: 40,
              ),
            ),
          ),
          PositionedDirectional(
            start: 56.w,
            end: 56.w,
            bottom: 0,
            child: const CheckeredStrip(
              rows: 2,
              squareSize: 7,
              color: AppTheme.onPrimaryColor,
              opacity: 0.28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step caption plus tappable page dots, so the slides can be reached without
/// swiping too. Listenable so only this footer rebuilds while the student moves.
class _StepFooter extends StatelessWidget {
  const _StepFooter({required this.page, required this.count, required this.onSelect});

  /// Owned and disposed by the parent state.
  final ValueListenable<int> page;
  final int count;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: page,
      builder: (context, current, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'onboarding.stepOf'.tr(namedArgs: {'current': '${current + 1}', 'total': '$count'}),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.onPrimaryColor.withValues(alpha: 0.72),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < count; i++)
                    Pressable(
                      onTap: () => onSelect(i),
                      pressedScale: 0.85,
                      semanticLabel: 'onboarding.stepOf'.tr(
                        namedArgs: {'current': '${i + 1}', 'total': '$count'},
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 9.h),
                        child: AnimatedContainer(
                          duration: AppTheme.animationNormal,
                          curve: AppTheme.slideCurve,
                          width: current == i ? 24.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            gradient: current == i ? AppTheme.goldGradient : null,
                            color: current == i
                                ? null
                                : AppTheme.onPrimaryColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            boxShadow: current == i
                                ? AppTheme.glowShadow(AppTheme.signalYellow, strength: 0.5)
                                : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
