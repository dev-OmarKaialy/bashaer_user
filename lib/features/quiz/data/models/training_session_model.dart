import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_session_model.freezed.dart';
part 'training_session_model.g.dart';

/// Lifecycle of a training session: running, finished every category, or
/// ended early by the student.
enum TrainingSessionStatus { active, completed, stopped }

/// The score of one finished category inside a training session.
@freezed
sealed class CategoryRoundResult with _$CategoryRoundResult {
  const factory CategoryRoundResult({
    required String categoryId,
    required String categoryName,
    required int correctAttempts,
    required int totalAttempts,
  }) = _CategoryRoundResult;

  const CategoryRoundResult._();

  factory CategoryRoundResult.fromJson(Map<String, dynamic> json) =>
      _$CategoryRoundResultFromJson(json);

  static CategoryRoundResult CategoryRoundResultFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return CategoryRoundResult.fromJson(decoded);
  }

  int get wrongAttempts => totalAttempts - correctAttempts;

  /// Net points earned in this category (+1 per correct, −1 per wrong attempt),
  /// before the session-wide floor at zero.
  int get points => correctAttempts - wrongAttempts;

  double get accuracy => totalAttempts == 0 ? 0 : (correctAttempts / totalAttempts) * 100;
}

/// A training run through every category in order, persisted locally so it
/// can be resumed and kept in the history once it ends.
@freezed
sealed class TrainingSessionModel with _$TrainingSessionModel {
  const factory TrainingSessionModel({
    required String id,
    required int startedAt,
    int? endedAt,
    @Default(TrainingSessionStatus.active) TrainingSessionStatus status,
    @Default(<String>[]) List<String> categoryIds,
    @Default(0) int currentCategoryIndex,

    /// Session total, never below zero.
    @Default(0) int points,

    /// Attempts made so far in the current (unfinished) category.
    @Default(0) int currentCorrectAttempts,
    @Default(0) int currentTotalAttempts,

    /// Questions already answered correctly in the current category.
    @Default(<String>[]) List<String> solvedQuestionIds,
    @Default(<CategoryRoundResult>[]) List<CategoryRoundResult> categoryResults,
  }) = _TrainingSessionModel;

  const TrainingSessionModel._();

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionModelFromJson(json);

  static TrainingSessionModel TrainingSessionModelFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return TrainingSessionModel.fromJson(decoded);
  }

  String? get currentCategoryId =>
      currentCategoryIndex < categoryIds.length ? categoryIds[currentCategoryIndex] : null;

  bool get isLastCategory => currentCategoryIndex >= categoryIds.length - 1;

  int get correctAttempts =>
      categoryResults.fold(currentCorrectAttempts, (sum, r) => sum + r.correctAttempts);

  int get totalAttempts =>
      categoryResults.fold(currentTotalAttempts, (sum, r) => sum + r.totalAttempts);

  int get wrongAttempts => totalAttempts - correctAttempts;

  double get accuracy => totalAttempts == 0 ? 0 : (correctAttempts / totalAttempts) * 100;
}
