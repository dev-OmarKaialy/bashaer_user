import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_app_bar.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/road_progress_bar.dart';
import '../../data/models/category_model.dart';
import '../../data/models/stats_model.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_state.dart';
import '../bloc/quiz_event.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_placeholder.dart';
import '../widgets/exam_start_lights.dart';
import 'quiz_screen.dart';

/// Practice by topic: one "track" card per category with its question count
/// and the user's running accuracy for that category.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RaceAppBar(title: 'categories.title'.tr()),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return RaceLoader(label: 'home.loading'.tr());
          }
          final categories = state.categoriesWithCount();
          if (categories.isEmpty) {
            return EmptyPlaceholder(icon: Icons.category_rounded, message: 'categories.empty'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
            itemCount: categories.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (context, index) => Entrance(
              index: index,
              child: _CategoryTile(category: categories[index], index: index),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.index});

  final CategoryModel category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final stats = context.select<ProgressBloc, StatsModel?>((state) => state.state.stats);
    final catStat = stats?.categoryStats[category.id];
    final accuracy = catStat == null || catStat.answered == 0 ? null : catStat.accuracy.round();
    final gradient = AppTheme.accentGradientAt(index);

    void startPractice() async {
      final all = context.read<ProgressBloc>().state.questions;
      await showRaceStartLights(
        context,
        getReadyLabel: 'practice.getReady'.tr(),
        goLabel: 'practice.go'.tr(),
      );
      if (!context.mounted) return;
      unawaited(
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuizScreen(
              questions: all.where((q) => q.categoryId == category.id).toList(),
              mode: QuizMode.practice,
              title: category.name,
            ),
          ),
        ),
      );
    }

    return RaceCard(
      onTap: startPractice,
      semanticLabel: '${'categories.practice'.tr()} ${category.name}',
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GradientIconBadge(
                gradient: gradient,
                size: 56,
                child: CategoryIcon(
                  name: category.icon,
                  size: 24.r,
                  color: AppTheme.onPrimaryColor,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        RaceTag(
                          label: '${category.questionCount} ${'categories.count'.tr()}',
                          color: gradient.colors.first,
                          icon: Icons.quiz_rounded,
                        ),
                        if (accuracy != null)
                          RaceTag(
                            label: '${'categories.accuracy'.tr()} $accuracy%',
                            color: AppTheme.scoreColor(accuracy.toDouble()),
                            icon: Icons.speed_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowShadow(gradient.colors.first, strength: 0.5),
                ),
                child: SizedBox(
                  width: 44.r,
                  height: 44.r,
                  child: Icon(Icons.play_arrow_rounded, color: AppTheme.onPrimaryColor, size: 28.r),
                ),
              ),
            ],
          ),
          if (accuracy != null) ...[
            SizedBox(height: 12.h),
            RoadProgressBar(
              progress: accuracy / 100,
              gradient: gradient,
              height: 10,
              showCar: false,
            ),
          ],
        ],
      ),
    );
  }
}
