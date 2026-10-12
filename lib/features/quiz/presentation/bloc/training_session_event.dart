import 'package:equatable/equatable.dart';

sealed class TrainingSessionEvent extends Equatable {
  const TrainingSessionEvent();

  @override
  List<Object?> get props => [];
}

/// Reads the session history. A session left unfinished is archived as
/// stopped, never resumed.
final class LoadTrainingSessionEvent extends TrainingSessionEvent {
  const LoadTrainingSessionEvent();
}

/// Starts a fresh session over [categoryIds] in order (from the chosen start
/// category to the last). An unfinished session is ended as stopped first.
final class StartTrainingSessionEvent extends TrainingSessionEvent {
  const StartTrainingSessionEvent({required this.categoryIds});

  final List<String> categoryIds;

  @override
  List<Object?> get props => [categoryIds];
}

/// Snapshot of the current category after an answer attempt, persisted so an
/// interrupted session still reaches the history.
final class RecordAttemptTrainingSessionEvent extends TrainingSessionEvent {
  const RecordAttemptTrainingSessionEvent({
    required this.points,
    required this.correctAttempts,
    required this.totalAttempts,
    required this.solvedQuestionIds,
    required this.streak,
  });

  /// Session total after the attempt.
  final int points;

  /// Attempt counters for the current category.
  final int correctAttempts;
  final int totalAttempts;
  final List<String> solvedQuestionIds;

  /// Correct answers in a row after the attempt, carried to the next category.
  final int streak;

  @override
  List<Object?> get props => [points, correctAttempts, totalAttempts, solvedQuestionIds, streak];
}

/// Every question of the current category was answered correctly: archive the
/// round and move to the next category, or complete the session after the last.
final class CompleteCategoryTrainingSessionEvent extends TrainingSessionEvent {
  const CompleteCategoryTrainingSessionEvent({
    required this.categoryName,
    required this.points,
    required this.correctAttempts,
    required this.totalAttempts,
  });

  final String categoryName;
  final int points;
  final int correctAttempts;
  final int totalAttempts;

  @override
  List<Object?> get props => [categoryName, points, correctAttempts, totalAttempts];
}

/// The student ended the session before finishing every category.
final class StopTrainingSessionEvent extends TrainingSessionEvent {
  const StopTrainingSessionEvent();
}
