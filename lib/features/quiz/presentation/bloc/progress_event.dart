import 'package:equatable/equatable.dart';

import '../../data/models/quiz_result_model.dart';

sealed class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProgressEvent extends ProgressEvent {
  const LoadProgressEvent();
}

final class ToggleBookmarkFromProgress extends ProgressEvent {
  const ToggleBookmarkFromProgress({required this.questionId});

  final String questionId;

  @override
  List<Object?> get props => [questionId];
}

final class SaveResultProgressEvent extends ProgressEvent {
  const SaveResultProgressEvent({required this.result});

  final QuizResultModel result;

  @override
  List<Object?> get props => [result];
}

/// Re-pulls the question bank from Firestore, then reloads progress.
final class RefreshBankEvent extends ProgressEvent {
  const RefreshBankEvent();
}

/// Wipes the answer log and exam results, keeping bookmarks.
final class ClearStatisticsEvent extends ProgressEvent {
  const ClearStatisticsEvent();
}

/// Wipes the bookmarked questions, keeping statistics.
final class ClearBookmarksEvent extends ProgressEvent {
  const ClearBookmarksEvent();
}
