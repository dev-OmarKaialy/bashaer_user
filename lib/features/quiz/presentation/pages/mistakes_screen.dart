import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/request_status.dart';
import '../../../../core/widgets/race/entrance.dart';
import '../../../../core/widgets/race/race_app_bar.dart';
import '../../../../core/widgets/race/race_button.dart';
import '../../../../core/widgets/race/race_loader.dart';
import '../../data/models/question_model.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_state.dart';
import '../bloc/quiz_event.dart';
import '../widgets/empty_placeholder.dart';
import '../widgets/exam_start_lights.dart';
import '../widgets/question_list_tile.dart';
import 'quiz_screen.dart';

/// Questions answered incorrectly during practice, most recent first, with the
/// number of times each one was missed. Tapping opens a targeted practice.
class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  String _categoryName(ProgressState state, String categoryId) {
    for (final c in state.categories) {
      if (c.id == categoryId) return c.name;
    }
    return '';
  }

  Future<void> _practice(BuildContext context, List<QuestionModel> questions) async {
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
            questions: questions,
            mode: QuizMode.practice,
            title: 'mistakes.title'.tr(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RaceAppBar(title: 'mistakes.title'.tr()),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state.status.isLoading && state.questions.isEmpty) {
            return RaceLoader(label: 'home.loading'.tr());
          }

          final wrongEntries = state.answerLog.where((e) => !e.correct).toList()
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          final questionById = <String, QuestionModel>{for (final q in state.questions) q.id: q};
          final missedCount = <String, int>{};
          for (final e in wrongEntries) {
            missedCount.update(e.questionId, (v) => v + 1, ifAbsent: () => 1);
          }
          final missedQuestions = missedCount.entries
              .where((e) => questionById.containsKey(e.key))
              .map((e) => (question: questionById[e.key]!, count: e.value))
              .toList();

          if (missedQuestions.isEmpty) {
            return EmptyPlaceholder(
              icon: Icons.emoji_events_rounded,
              message: 'mistakes.empty'.tr(),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
            itemCount: missedQuestions.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Entrance(
                  child: RaceButton(
                    label: '${'mistakes.practiceAll'.tr()} (${missedQuestions.length})',
                    icon: Icons.replay_rounded,
                    gradient: AppTheme.dangerGradient,
                    shine: true,
                    fullWidth: true,
                    onPressed: () =>
                        _practice(context, missedQuestions.map((m) => m.question).toList()),
                  ),
                );
              }
              final item = missedQuestions[index - 1];
              return Entrance(
                index: index,
                child: QuestionListTile(
                  question: item.question,
                  subtitle: _categoryName(state, item.question.categoryId),
                  onTap: () => _practice(context, missedQuestions.map((m) => m.question).toList()),
                  trailingIcon: Icons.replay_rounded,
                  trailingColor: AppTheme.racingRed,
                  countBadge: '${item.count}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
