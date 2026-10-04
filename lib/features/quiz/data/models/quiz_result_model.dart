import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_result_model.freezed.dart';
part 'quiz_result_model.g.dart';

/// A completed quiz/exam attempt, persisted locally for history and statistics.
@freezed
sealed class QuizResultModel with _$QuizResultModel {
  const factory QuizResultModel({
    required String id,
    required String examTitle,
    required int dateTime,
    required int totalQuestions,
    required int answered,
    required int correct,
    required int wrong,
    required int unanswered,
    required int totalTimeSeconds,
    required int timeUsedSeconds,
    @Default(0) int passingScore,
    @Default(false) bool passed,
    @Default(<String, int>{}) Map<String, int> correctByCategory,
    @Default(<String, int>{}) Map<String, int> totalByCategory,
  }) = _QuizResultModel;

  const QuizResultModel._();

  factory QuizResultModel.fromJson(Map<String, dynamic> json) => _$QuizResultModelFromJson(json);

  static QuizResultModel QuizResultModelFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return QuizResultModel.fromJson(decoded);
  }

  static List<QuizResultModel> listFromJsonArray(List<dynamic> jsonList) {
    return jsonList.map((e) => QuizResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  double get accuracy => totalQuestions == 0 ? 0 : (correct / totalQuestions) * 100;
}

/// Single question-answer log entry used to derive mistakes and statistics.
@freezed
sealed class AnswerLogEntry with _$AnswerLogEntry {
  const factory AnswerLogEntry({
    required String questionId,
    required bool correct,
    required int dateTime,
  }) = _AnswerLogEntry;

  const AnswerLogEntry._();

  factory AnswerLogEntry.fromJson(Map<String, dynamic> json) => _$AnswerLogEntryFromJson(json);

  static AnswerLogEntry AnswerLogEntryFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return AnswerLogEntry.fromJson(decoded);
  }
}
