import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_contact.dart';
import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/checkered_flag.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/motion_loop.dart';
import '../../../../core/widgets/race/pressable.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/speed_lines_background.dart';
import '../../../license/presentation/pages/license_gate_screen.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

/// What the monthly subscription includes and how to get it: the price the
/// school published on Firestore, the benefits, and a way to reach the teacher
/// on WhatsApp or by phone.
class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubscriptionCubit>()..loadPlan(),
      child: const _SubscribeView(),
    );
  }
}

class _SubscribeView extends StatefulWidget {
  const _SubscribeView();

  @override
  State<_SubscribeView> createState() => _SubscribeViewState();
}

class _SubscribeViewState extends State<_SubscribeView> {
  /// One-shot confetti when the price first becomes available. Owned here so
  /// the overlay can sit above the list without rebuilding the whole screen.
  final ValueNotifier<bool> _showConfetti = ValueNotifier<bool>(false);
  bool _confettiFired = false;

  @override
  void dispose() {
    _showConfetti.dispose();
    super.dispose();
  }

  void _onPriceReady() {
    if (_confettiFired || MediaQuery.disableAnimationsOf(context)) return;
    _confettiFired = true;
    _showConfetti.value = true;
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _showConfetti.value = false;
    });
  }

  /// Hands the student over to the school, then leaves the funnel: the app is
  /// theirs to use once the device is approved.
  void _checkSubscription(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LicenseGateScreen()),
      (route) => false,
    );
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
                child: BlocListener<SubscriptionCubit, SubscriptionState>(
                  listenWhen: (previous, current) =>
                      previous.status != current.status || previous.plan != current.plan,
                  listener: (context, state) {
                    if (state.status.isSuccess && state.plan?.priceLabel != null) {
                      _onPriceReady();
                    }
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
                    children: [
                      const Entrance(scale: true, child: _SubscribeHero()),
                      SizedBox(height: 8.h),
                      const Entrance(index: 1, child: _SubscribeTitleBlock()),
                      SizedBox(height: 18.h),
                      const Entrance(index: 2, child: _PriceCard()),
                      SizedBox(height: 24.h),
                      Entrance(
                        index: 3,
                        child: SectionHeader(
                          title: 'subscribe.benefitsTitle'.tr(),
                          color: AppTheme.signalYellow,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      const _BenefitList(),
                      SizedBox(height: 26.h),
                      Entrance(
                        index: 4,
                        child: _ContactActions(onCheckSubscription: _checkSubscription),
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _showConfetti,
                builder: (context, show, _) {
                  if (!show) return const SizedBox.shrink();
                  return IgnorePointer(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AppLottie(
                        asset: LottieAssets.confetti,
                        size: 320.r,
                        repeat: false,
                        semanticLabel: 'subscribe.title'.tr(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onboarding-style hero: floating premium Lottie, glowing halo, badges and a
/// finish-line strip.
class _SubscribeHero extends StatelessWidget {
  const _SubscribeHero();

  @override
  Widget build(BuildContext context) {
    const accent = AppTheme.goldGradient;
    final accentColor = accent.colors.first;
    return SizedBox(
      height: 230.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: MotionLoop(
              scale: 1.1,
              duration: const Duration(milliseconds: 3400),
              child: Container(
                width: 210.r,
                height: 210.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accentColor.withValues(alpha: 0.45), accentColor.withValues(alpha: 0)],
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
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                child: AppLottie(
                  asset: LottieAssets.premium,
                  size: 120.r,
                  semanticLabel: 'subscribe.title'.tr(),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 8.w,
            top: 16.h,
            child: MotionLoop(
              offset: Offset(0, -12.h),
              scale: 1.06,
              duration: const Duration(milliseconds: 2400),
              child: const GradientIconBadge(
                gradient: AppTheme.sunsetGradient,
                icon: Icons.workspace_premium_rounded,
                size: 46,
              ),
            ),
          ),
          PositionedDirectional(
            end: 6.w,
            bottom: 36.h,
            child: MotionLoop(
              offset: Offset(0, 12.h),
              scale: 1.05,
              duration: const Duration(milliseconds: 2700),
              child: const GradientIconBadge(
                gradient: AppTheme.candyGradient,
                icon: Icons.lock_open_rounded,
                size: 40,
              ),
            ),
          ),
          PositionedDirectional(
            start: 48.w,
            end: 48.w,
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

class _SubscribeTitleBlock extends StatelessWidget {
  const _SubscribeTitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaceTag(
              label: 'subscribe.monthlyBadge'.tr(),
              color: AppTheme.signalYellow,
              icon: Icons.workspace_premium_rounded,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'subscribe.title'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onPrimaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'subscribe.subtitle'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.82)),
        ),
      ],
    );
  }
}

/// The monthly price from Firestore. Only this card rebuilds while the plan
/// loads, so the rest of the screen stays put.
class _PriceCard extends StatelessWidget {
  const _PriceCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (previous, current) =>
          previous.status != current.status || previous.plan != current.plan,
      builder: (context, state) {
        if (state.status.isLoading || state.status.isInit) {
          return RaceCard(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: RaceLoader(label: 'subscribe.loadingPrice'.tr()),
          );
        }

        final priceLabel = state.plan?.priceLabel;
        if (priceLabel == null) {
          return RaceCard(
            padding: EdgeInsets.all(16.r),
            borderColor: AppTheme.signalYellow.withValues(alpha: 0.35),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.signalYellow, size: 24.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'subscribe.priceUnavailable'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return MotionLoop(
          scale: 1.03,
          duration: const Duration(milliseconds: 3200),
          child: RaceCard(
            gradient: AppTheme.sunsetGradient,
            glowColor: AppTheme.sunsetGradient.colors.first,
            radius: AppTheme.radiusXXL,
            padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppLottie(asset: LottieAssets.sparkle, size: 28.r),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'subscribe.priceCaption'.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AppLottie(asset: LottieAssets.sparkle, size: 28.r),
                  ],
                ),
                SizedBox(height: 8.h),
                Entrance(
                  scale: true,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      priceLabel,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.onPrimaryColor,
                        fontFamily: AppTheme.displayNumberFont,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'subscribe.perMonth'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onPrimaryColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Benefits from the plan document, falling back to the bundled list when the
/// school has not published one.
class _BenefitList extends StatelessWidget {
  const _BenefitList();

  static const List<String> _fallbackKeys = [
    'subscribe.benefit1',
    'subscribe.benefit2',
    'subscribe.benefit3',
    'subscribe.benefit4',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (previous, current) => previous.plan != current.plan,
      builder: (context, state) {
        final features = state.plan?.features ?? const <String>[];
        final items = features.isNotEmpty
            ? features
            : _fallbackKeys.map((key) => key.tr()).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              Entrance(
                index: i,
                child: _BenefitTile(text: items[i], index: i),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.text, required this.index});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentGradients[index % AppTheme.accentGradients.length].colors.first;
    return Pressable(
      onTap: () {},
      pressedScale: 0.97,
      semanticLabel: text,
      child: RaceCard(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        borderColor: accent.withValues(alpha: 0.24),
        child: Row(
          children: [
            MotionLoop(
              scale: 1.08,
              duration: Duration(milliseconds: 2400 + (index * 180)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 36.r,
                  height: 36.r,
                  child: Center(
                    child: AppLottie(asset: LottieAssets.sparkle, size: 22.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(height: 1.4),
              ),
            ),
            Icon(Icons.check_circle_rounded, color: accent, size: 20.r),
          ],
        ),
      ),
    );
  }
}

/// The two ways to reach the school, plus the way into the subscription check
/// for students who already paid.
class _ContactActions extends StatelessWidget {
  const _ContactActions({required this.onCheckSubscription});

  final ValueChanged<BuildContext> onCheckSubscription;

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!opened) Toaster.showToast('subscribe.openFailed'.tr());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: MotionLoop(
            offset: Offset(0, 6.h),
            scale: 1.04,
            duration: const Duration(milliseconds: 2800),
            child: AppLottie(
              asset: LottieAssets.chat,
              size: 110.r,
              semanticLabel: 'subscribe.contactTitle'.tr(),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'subscribe.contactTitle'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.onPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'subscribe.contactSubtitle'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.onPrimaryColor.withValues(alpha: 0.75)),
        ),
        SizedBox(height: 14.h),
        if (AppContact.whatsapp.isNotEmpty) ...[
          RaceButton(
            label: 'subscribe.whatsapp'.tr(),
            icon: Icons.chat_rounded,
            gradient: AppTheme.limeGradient,
            shine: true,
            fullWidth: true,
            onPressed: () => _open(context, Uri.parse('https://wa.me/${AppContact.whatsapp}')),
          ),
          SizedBox(height: 10.h),
        ],
        if (AppContact.phone.isNotEmpty) ...[
          RaceButton(
            label: 'subscribe.call'.tr(),
            icon: Icons.call_rounded,
            gradient: AppTheme.oceanGradient,
            fullWidth: true,
            onPressed: () => _open(context, Uri(scheme: 'tel', path: AppContact.phone)),
          ),
          SizedBox(height: 10.h),
        ],
        RaceButton(
          label: 'subscribe.checkSubscription'.tr(),
          icon: Icons.phonelink_lock_rounded,
          variant: RaceButtonVariant.outline,
          gradient: AppTheme.grapeGradient,
          fullWidth: true,
          onPressed: () => onCheckSubscription(context),
        ),
        if (AppContact.whatsapp.isEmpty && AppContact.phone.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'subscribe.contactUnavailable'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onPrimaryColor.withValues(alpha: 0.75),
              ),
            ),
          ),
      ],
    );
  }
}
