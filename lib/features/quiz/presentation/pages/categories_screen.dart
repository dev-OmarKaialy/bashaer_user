import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_app_bar.dart';
import '../../../../core/widgets/race/race_card.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../../../core/widgets/race/road_progress_bar.dart';
import '../../data/models/category_model.dart';
import '../../data/models/stats_model.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_state.dart';
import '../bloc/training_session_bloc.dart';
import '../bloc/training_session_event.dart';
import '../bloc/training_session_state.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_placeholder.dart';
import 'training_navigation.dart';

/// Training start: one "track" card per category with its question count and
/// the user's running accuracy. Tapping one starts a training session from
/// that category to the last, in order.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrainingSessionBloc, TrainingSessionState>(
      listenWhen: (prev, curr) => prev.startStatus != curr.startStatus,
      listener: (context, state) {
        if (state.startStatus.isSuccess) openTrainingRound(context);
        if (state.startStatus.isFailed) Toaster.showToast('training.startFailed'.tr());
      },
      child: Scaffold(
        appBar: RaceAppBar(title: 'categories.title'.tr()),
        body: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state.status.isLoading) {
              return RaceLoader(label: 'home.loading'.tr());
            }
            final categories = state.categoriesWithCount();
            if (categories.isEmpty) {
              return EmptyPlaceholder(
                icon: Icons.category_rounded,
                message: 'categories.empty'.tr(),
              );
            }
            final trainable = state.trainingCategoryIds();
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                if (index == 0) return const Entrance(child: _PickStartHint());
                final category = categories[index - 1];
                final position = trainable.indexOf(category.id);
                return Entrance(
                  index: index,
                  child: _CategoryTile(
                    category: category,
                    index: index - 1,
                    remaining: position < 0 ? 0 : trainable.length - position,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Explains the flow: the chosen category is only where the run begins.
class _PickStartHint extends StatelessWidget {
  const _PickStartHint();

  @override
  Widget build(BuildContext context) {
    return RaceCard(
      color: AppTheme.mutedSurface,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.flag_circle_rounded, color: AppTheme.nitroBlue, size: 30.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text('training.pickStart'.tr(), style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.index, required this.remaining});

  final CategoryModel category;
  final int index;

  /// Categories the run goes through when started here, this one included.
  /// Zero when the category has no questions.
  final int remaining;

  void _startTraining(BuildContext context) {
    final categoryIds = context.read<ProgressBloc>().state.trainingCategoryIds(
      startFrom: category.id,
    );
    context.read<TrainingSessionBloc>().add(StartTrainingSessionEvent(categoryIds: categoryIds));
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.select<ProgressBloc, StatsModel?>((state) => state.state.stats);
    final catStat = stats?.categoryStats[category.id];
    final accuracy = catStat == null || catStat.answered == 0 ? null : catStat.accuracy.round();
    final gradient = AppTheme.accentGradientAt(index);

    return RaceCard(
      onTap: remaining == 0 ? null : () => _startTraining(context),
      semanticLabel: '${'training.startFrom'.tr()} ${category.name}',
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
                        if (remaining > 1)
                          RaceTag(
                            label: 'training.toFinish'.tr(namedArgs: {'count': '$remaining'}),
                            color: AppTheme.inkSoft,
                            icon: Icons.sports_score_rounded,
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
