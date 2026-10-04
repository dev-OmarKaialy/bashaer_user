import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/race/pressable.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

/// "Pit board" bottom sheet listing every question number coloured by its
/// state (current, correct, wrong, unanswered) so the user can jump directly.
class QuestionsGridSheet extends StatelessWidget {
  const QuestionsGridSheet({super.key});

  void open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      builder: (_) => BlocProvider.value(value: context.read<QuizBloc>(), child: this),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_score_rounded, color: AppTheme.turboOrange, size: 24.r),
              SizedBox(width: 8.w),
              Text('quiz.review'.tr(), style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          SizedBox(height: 12.h),
          const _Legend(),
          SizedBox(height: 16.h),
          Flexible(
            child: BlocBuilder<QuizBloc, QuizState>(
              buildWhen: (prev, curr) =>
                  prev.currentIndex != curr.currentIndex ||
                  prev.selectedAnswers != curr.selectedAnswers ||
                  prev.correctnessByQuestion != curr.correctnessByQuestion ||
                  prev.questions != curr.questions,
              builder: (context, state) {
                final answers = state.selectedAnswers;
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10.r,
                    crossAxisSpacing: 10.r,
                  ),
                  itemCount: state.totalQuestions,
                  itemBuilder: (context, index) {
                    final question = state.questions[index];
                    final selected = answers[question.id] ?? const <String>{};
                    return _GridCell(
                      index: index,
                      isCurrent: index == state.currentIndex,
                      hasSelection: selected.isNotEmpty,
                      isCorrect: question.isSelectionCorrect(selected),
                      isLocked: !state.isQuestionUnlocked(index),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.index,
    required this.isCurrent,
    required this.hasSelection,
    required this.isCorrect,
    required this.isLocked,
  });

  final int index;
  final bool isCurrent;
  final bool hasSelection;
  final bool isCorrect;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final Color color = !hasSelection
        ? (isLocked ? AppTheme.inkFaint : AppTheme.inkSoft)
        : isCorrect
        ? AppTheme.successColor
        : AppTheme.dangerColor;
    final Color background = !hasSelection
        ? AppTheme.cardSurface
        : isCorrect
        ? AppTheme.successBackgroundColor
        : AppTheme.dangerBackgroundColor;

    return Pressable(
      onTap: isLocked
          ? null
          : () {
              context.read<QuizBloc>().add(GoToQuestionEvent(index: index));
              Navigator.pop(context);
            },
      pressedScale: 0.9,
      semanticLabel: isLocked
          ? '${'quiz.question'.tr()} ${index + 1}, ${'quiz.legendLocked'.tr()}'
          : '${'quiz.question'.tr()} ${index + 1}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isCurrent ? AppTheme.oceanGradient : null,
          color: isCurrent ? null : background,
          borderRadius: BorderRadius.circular(AppTheme.radiusS.r),
          border: isCurrent ? null : Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
          boxShadow: isCurrent ? AppTheme.glowShadow(AppTheme.nitroBlue, strength: 0.4) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${index + 1}',
                style: AppTheme.numberStyle(
                  15.sp,
                  color: isCurrent ? AppTheme.onPrimaryColor : color,
                ),
              ),
            ),
            if (isLocked)
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(top: 3.r, end: 3.r),
                    child: Icon(Icons.lock_rounded, size: 13.r, color: AppTheme.inkFaint),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final items = <({String label, Color color, IconData? icon})>[
      (label: 'quiz.legendCurrent'.tr(), color: AppTheme.nitroBlue, icon: null),
      (label: 'quiz.legendCorrect'.tr(), color: AppTheme.successColor, icon: null),
      (label: 'quiz.legendWrong'.tr(), color: AppTheme.dangerColor, icon: null),
      (label: 'quiz.legendUnanswered'.tr(), color: AppTheme.inkFaint, icon: null),
      (label: 'quiz.legendLocked'.tr(), color: AppTheme.inkFaint, icon: Icons.lock_rounded),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14.w,
      runSpacing: 6.h,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null)
                Icon(item.icon, color: item.color, size: 14.r)
              else
                DecoratedBox(
                  decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                  child: SizedBox(width: 10.r, height: 10.r),
                ),
              SizedBox(width: 6.w),
              Text(item.label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
      ],
    );
  }
}
