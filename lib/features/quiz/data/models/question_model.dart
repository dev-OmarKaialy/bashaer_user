import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

/// Question kinds the quiz engine understands.
enum QuestionType { singleChoice, multipleChoice, trueFalse }

QuestionType questionTypeFromJson(Object? value) {
  switch (value?.toString()) {
    case 'multiple_choice':
      return QuestionType.multipleChoice;
    case 'true_false':
      return QuestionType.trueFalse;
    case 'single_choice':
    default:
      return QuestionType.singleChoice;
  }
}

String questionTypeToJson(QuestionType type) {
  switch (type) {
    case QuestionType.multipleChoice:
      return 'multiple_choice';
    case QuestionType.trueFalse:
      return 'true_false';
    case QuestionType.singleChoice:
      return 'single_choice';
  }
}

@freezed
sealed class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required String id,
    required String text,
    @Default(false) bool isCorrect,
    String? image,
    String? description,
  }) = _AnswerModel;

  const AnswerModel._();

  factory AnswerModel.fromJson(Map<String, dynamic> json) => _$AnswerModelFromJson(json);
}

@freezed
sealed class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required String categoryId,
    @JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson) required QuestionType type,
    required String title,

    /// Optional media URL (Firestore Storage / HTTPS). Title is always required.
    String? image,

    /// Optional pre-recorded question audio (Firestore Storage / HTTPS).
    /// When set, Listen mode plays this instead of device TTS.
    String? audio,
    String? description,
    required List<AnswerModel> answers,
    @Default(<String>[]) List<String> correctAnswerIds,
    String? hint,
    String? explanation,
    String? difficulty,
    @Default(1) int points,
  }) = _QuestionModel;

  const QuestionModel._();

  factory QuestionModel.fromJson(Map<String, dynamic> json) => _$QuestionModelFromJson(json);

  /// Convenience parser matching the project's `<name>FromJson(String)` style.
  static QuestionModel QuestionModelFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return QuestionModel.fromJson(decoded);
  }

  /// Whether the given selection is exactly the configured correct answer set.
  bool isSelectionCorrect(Set<String> selectedAnswerIds) {
    final correct = correctAnswerIds.toSet();
    if (correct.isEmpty) return false;
    return selectedAnswerIds.length == correct.length && selectedAnswerIds.containsAll(correct);
  }

  /// Whether at least one answer was selected for this question.
  bool isAnswered(Set<String> selectedAnswerIds) => selectedAnswerIds.isNotEmpty;
}
