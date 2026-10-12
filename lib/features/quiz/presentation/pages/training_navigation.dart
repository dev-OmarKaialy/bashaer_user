import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/progress_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/training_session_bloc.dart';
import '../bloc/training_session_event.dart';
import '../widgets/exam_start_lights.dart';
import 'quiz_screen.dart';
import 'training_results_screen.dart';

/// Opens the quiz for the active training session's current category, after
/// the start lights. [replace] swaps it in for the current route (moving on
/// from the previous category). Does nothing when no session is running.
Future<void> openTrainingRound(BuildContext context, {bool replace = false}) async {
  final session = context.read<TrainingSessionBloc>().state.session;
  final categoryId = session?.currentCategoryId;
  if (session == null || categoryId == null) return;

  final progress = context.read<ProgressBloc>().state;
  final questions = progress.questions.where((q) => q.categoryId == categoryId).toList();
  final category = progress.categories.where((c) => c.id == categoryId).firstOrNull;

  await showRaceStartLights(
    context,
    getReadyLabel: 'practice.getReady'.tr(),
    goLabel: 'practice.go'.tr(),
  );
  if (!context.mounted) return;

  final route = MaterialPageRoute<void>(
    builder: (_) => QuizScreen(
      questions: questions,
      mode: QuizMode.practice,
      title: category?.name,
      trainingSession: session,
    ),
  );
  final navigator = Navigator.of(context);
  if (replace) {
    await navigator.pushReplacement(route);
  } else {
    await navigator.push(route);
  }
}

/// Replaces the current route with the results of the session that just
/// ended, or returns home when there is none (or nothing was answered).
void openTrainingResults(BuildContext context) {
  final finished = context.read<TrainingSessionBloc>().state.finishedSession;
  final navigator = Navigator.of(context);
  if (finished == null || finished.totalAttempts == 0) {
    navigator.popUntil((route) => route.isFirst);
    return;
  }
  navigator.pushReplacement(
    MaterialPageRoute<void>(builder: (_) => TrainingResultsScreen(session: finished)),
  );
}

/// The student chose to stop before the last category: ends the running
/// session, then shows its results.
Future<void> finishTrainingNow(BuildContext context) async {
  final training = context.read<TrainingSessionBloc>();
  if (training.state.hasActiveSession) {
    training.add(const StopTrainingSessionEvent());
    await training.stream.firstWhere((state) => !state.hasActiveSession);
    if (!context.mounted) return;
  }
  openTrainingResults(context);
}
