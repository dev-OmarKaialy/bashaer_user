import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/lottie_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/animated_count.dart';
import '../../../../core/widgets/race/app_lottie.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_app_bar.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/speed_gauge.dart';
import '../../data/models/training_session_model.dart';
import 'categories_screen.dart';

/// Final results of a training session, whether it reached the last category
/// or was finished early: accuracy gauge, total points, attempt counts and the
/// score per category.
class TrainingResultsScreen extends StatelessWidget {
  const TrainingResultsScreen({super.key, required this.session});

  final TrainingSessionModel session;

  /// Back to the category list, to pick where the next run starts.
  void _startNew(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final rounds = session.categoryResults;
    return Scaffold(
      appBar: RaceAppBar(title: 'training.resultsTitle'.tr()),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            sliver: SliverList.list(
              children: [
                Entrance(scale: true, child: _ResultsHero(session: session)),
                SizedBox(height: 18.h),
                Entrance(index: 1, child: _AttemptTiles(session: session)),
                SizedBox(height: 26.h),
                SectionHeader(title: 'training.perCategory'.tr(), color: AppTheme.nitroBlue),
                SizedBox(height: 12.h),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList.builder(
              itemCount: rounds.length,
              itemBuilder: (context, i) => Entrance(
                index: i,
                child: _RoundRow(round: rounds[i], colorIndex: i),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: RaceButton(
                      label: 'training.newTraining'.tr(),
                      icon: Icons.replay_rounded,
                      gradient: AppTheme.sunsetGradient,
                      onPressed: () => _startNew(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: RaceButton(
                      label: 'result.home'.tr(),
                      icon: Icons.home_rounded,
                      variant: RaceButtonVariant.outline,
                      gradient: AppTheme.grapeGradient,
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsHero extends StatelessWidget {
  const _ResultsHero({required this.session});

  final TrainingSessionModel session;

  @override
  Widget build(BuildContext context) {
    // Ended early with "Finish now" rather than after the last category.
    final completed = session.status == TrainingSessionStatus.completed;
    return Stack(
      children: [
        RaceCard(
          gradient: AppTheme.heroGradient,
          glowColor: AppTheme.nitroBlue,
          radius: AppTheme.radiusXXL,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Column(
            children: [
              Row(
                children: [
                  AppLottie(asset: LottieAssets.trophy, size: 100.r, repeat: false),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completed
                              ? 'training.resultsHeadline'.tr()
                              : 'training.stoppedHeadline'.tr(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(color: AppTheme.onPrimaryColor),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          completed
                              ? 'training.resultsMessage'.tr()
                              : 'training.stoppedMessage'.tr(
                                  namedArgs: {'count': '${session.categoryResults.length}'},
                                ),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              SpeedGauge(
                value: session.accuracy,
                label: 'training.accuracy'.tr(),
                size: 190,
                onDark: true,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, color: AppTheme.signalYellow, size: 30.r),
                  SizedBox(width: 6.w),
                  AnimatedCount(
                    value: session.points,
                    style: AppTheme.numberStyle(30.sp, color: AppTheme.onPrimaryColor),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'training.points'.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppTheme.onPrimaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXXL.r),
              child: const AppLottie(
                asset: LottieAssets.confetti,
                repeat: false,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttemptTiles extends StatelessWidget {
  const _AttemptTiles({required this.session});

  final TrainingSessionModel session;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        label: 'training.attempts'.tr(),
        value: session.totalAttempts,
        gradient: AppTheme.oceanGradient,
      ),
      (
        label: 'training.correct'.tr(),
        value: session.correctAttempts,
        gradient: AppTheme.limeGradient,
      ),
      (
        label: 'training.wrong'.tr(),
        value: session.wrongAttempts,
        gradient: AppTheme.dangerGradient,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: RaceCard(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: items[i].gradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: SizedBox(width: 26.w, height: 5.h),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedCount(
                    value: items[i].value,
                    style: AppTheme.numberStyle(22.sp, color: items[i].gradient.colors.first),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoundRow extends StatelessWidget {
  const _RoundRow({required this.round, required this.colorIndex});

  final CategoryRoundResult round;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final accuracy = round.accuracy.round();
    final points = round.points;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: RaceCard(
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            GradientIconBadge(
              gradient: AppTheme.accentGradientAt(colorIndex),
              size: 40,
              child: Text(
                '${colorIndex + 1}',
                style: AppTheme.numberStyle(16.sp, color: AppTheme.onPrimaryColor),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    round.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'training.correctAttempts'.tr()}: '
                    '${round.correctAttempts}/${round.totalAttempts}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    points > 0 ? '+$points' : '$points',
                    style: AppTheme.numberStyle(
                      18.sp,
                      color: points >= 0 ? AppTheme.successColor : AppTheme.dangerColor,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                RaceTag(label: '$accuracy%', color: AppTheme.scoreColor(accuracy.toDouble())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
