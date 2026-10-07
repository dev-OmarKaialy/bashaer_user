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

/// Every question the user saved for later review. Tapping opens a practice
/// session limited to the saved questions.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  String _categoryName(ProgressState state, String categoryId) {
    for (final c in state.categories) {
      if (c.id == categoryId) return c.name;
    }
    return '';
  }

  Future<void> _practice(BuildContext context, List<QuestionModel> bookmarked) async {
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
            questions: bookmarked,
            mode: QuizMode.practice,
            title: 'bookmarks.title'.tr(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RaceAppBar(title: 'bookmarks.title'.tr()),
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          final bookmarked = state.questions
              .where((q) => state.bookmarkedIds.contains(q.id))
              .toList();
          if (state.status.isLoading && state.questions.isEmpty) {
            return RaceLoader(label: 'home.loading'.tr());
          }
          if (bookmarked.isEmpty) {
            return EmptyPlaceholder(icon: Icons.bookmark_rounded, message: 'bookmarks.empty'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
            itemCount: bookmarked.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Entrance(
                  child: RaceButton(
                    label: '${'bookmarks.practiceAll'.tr()} (${bookmarked.length})',
                    icon: Icons.play_arrow_rounded,
                    gradient: AppTheme.goldGradient,
                    shine: true,
                    fullWidth: true,
                    onPressed: () => _practice(context, bookmarked),
                  ),
                );
              }
              final question = bookmarked[index - 1];
              return Entrance(
                index: index,
                child: QuestionListTile(
                  question: question,
                  subtitle: _categoryName(state, question.categoryId),
                  trailingIcon: Icons.bookmark_rounded,
                  trailingColor: AppTheme.turboOrange,
                  onTap: () => _practice(context, bookmarked),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
