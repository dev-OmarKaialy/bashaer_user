import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/widgets/race/animated_count.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_app_bar.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/road_progress_bar.dart';
import '../../../../core/widgets/race/speed_gauge.dart';
import '../../data/models/category_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/models/stats_model.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_state.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_placeholder.dart';

/// Whole-app study statistics: accuracy gauge, exam dials, per-category
/// "fuel" bars and the lap history of full exams.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RaceAppBar(title: 'statistics.title'.tr()),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          final stats = state.stats;
          if (state.status.isLoading && stats == null) {
            return RaceLoader(label: 'home.loading'.tr());
          }
          if (stats == null) {
            return EmptyPlaceholder(icon: Icons.insights_rounded, message: 'statistics.empty'.tr());
          }
          final answeredCategories = [
            for (final (index, category) in state.categories.indexed)
              if ((stats.categoryStats[category.id]?.answered ?? 0) > 0)
                (index: index, category: category, stat: stats.categoryStats[category.id]!),
          ];
          final results = state.results.reversed.toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                sliver: SliverList.list(
                  children: [
                    Entrance(scale: true, child: _AccuracyHero(accuracy: stats.accuracy)),
                    SizedBox(height: 16.h),
                    Entrance(index: 1, child: _DialGrid(stats: stats)),
                    SizedBox(height: 26.h),
                    SectionHeader(
                      title: 'statistics.categoryTitle'.tr(),
                      color: AppTheme.mintGreen,
                    ),
                    SizedBox(height: 12.h),
                    if (answeredCategories.isEmpty)
                      _InlineEmpty(message: 'statistics.categoryEmpty'.tr()),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList.builder(
                  itemCount: answeredCategories.length,
                  itemBuilder: (context, i) => Entrance(
                    index: i,
                    child: _CategoryBar(
                      category: answeredCategories[i].category,
                      stat: answeredCategories[i].stat,
                      colorIndex: answeredCategories[i].index,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
                sliver: SliverList.list(
                  children: [
                    SectionHeader(
                      title: 'statistics.activityTitle'.tr(),
                      color: AppTheme.turboOrange,
                    ),
                    SizedBox(height: 12.h),
                    if (results.isEmpty) _InlineEmpty(message: 'statistics.activityEmpty'.tr()),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
                sliver: SliverList.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) => Entrance(
                    index: i,
                    child: _ResultRow(result: results[i], lap: results.length - i),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccuracyHero extends StatelessWidget {
  const _AccuracyHero({required this.accuracy});

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return RaceCard(
      gradient: AppTheme.heroGradient,
      glowColor: AppTheme.nitroBlue,
      radius: AppTheme.radiusXXL,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      child: Center(
        child: SpeedGauge(
          value: accuracy,
          label: 'statistics.overallAccuracy'.tr(),
          size: 210,
          onDark: true,
        ),
      ),
    );
  }
}

class _DialGrid extends StatelessWidget {
  const _DialGrid({required this.stats});

  final StatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'statistics.exams'.tr(),
                value: stats.examsTaken,
                icon: FontAwesomeIcons.flagCheckered,
                gradient: AppTheme.grapeGradient,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _MiniStat(
                label: 'statistics.best'.tr(),
                value: stats.bestExamScore,
                suffix: '%',
                icon: FontAwesomeIcons.trophy,
                gradient: AppTheme.limeGradient,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'statistics.average'.tr(),
                value: stats.averageExamScore.round(),
                suffix: '%',
                icon: FontAwesomeIcons.gaugeHigh,
                gradient: AppTheme.oceanGradient,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _MiniStat(
                label: 'statistics.totalWrong'.tr(),
                value: stats.totalWrong,
                icon: FontAwesomeIcons.carBurst,
                gradient: AppTheme.dangerGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.suffix = '',
  });

  final String label;
  final int value;
  final FaIconData icon;
  final LinearGradient gradient;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return RaceCard(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          GradientIconBadge(
            gradient: gradient,
            size: 42,
            child: FaIcon(icon, size: 18.r, color: AppTheme.onPrimaryColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCount(
                  value: value,
                  suffix: suffix,
                  style: AppTheme.numberStyle(20.sp, color: gradient.colors.first),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.category, required this.stat, required this.colorIndex});

  final CategoryModel category;
  final CategoryStat stat;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final accuracy = stat.accuracy.round();
    final gradient = AppTheme.accentGradientAt(colorIndex);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: RaceCard(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GradientIconBadge(
                  gradient: gradient,
                  size: 36,
                  child: CategoryIcon(
                    name: category.icon,
                    size: 15.r,
                    color: AppTheme.onPrimaryColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${stat.correct}/${stat.answered}',
                  style: AppTheme.numberStyle(13.sp, color: AppTheme.inkSoft),
                ),
                SizedBox(width: 8.w),
                RaceTag(label: '$accuracy%', color: AppTheme.scoreColor(accuracy.toDouble())),
              ],
            ),
            SizedBox(height: 10.h),
            RoadProgressBar(
              progress: stat.answered == 0 ? 0 : stat.correct / stat.answered,
              gradient: gradient,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.lap});

  final QuizResultModel result;
  final int lap;

  @override
  Widget build(BuildContext context) {
    final color = result.passed ? AppTheme.successColor : AppTheme.dangerColor;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: RaceCard(
        padding: EdgeInsets.all(12.r),
        child: Row(
          children: [
            GradientIconBadge(
              gradient: result.passed ? AppTheme.limeGradient : AppTheme.dangerGradient,
              size: 44,
              child: FaIcon(
                result.passed ? FontAwesomeIcons.flagCheckered : FontAwesomeIcons.carBurst,
                size: 18.r,
                color: AppTheme.onPrimaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'statistics.lap'.tr()} $lap · ${result.examTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'result.correct'.tr()}: ${result.correct}/${result.totalQuestions}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text('${result.accuracy.round()}%', style: AppTheme.numberStyle(20.sp, color: color)),
          ],
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RaceCard(
      color: AppTheme.mutedSurface,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.inkSoft, size: 22.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
