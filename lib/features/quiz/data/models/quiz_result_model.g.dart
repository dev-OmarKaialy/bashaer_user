// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuizResultModel _$QuizResultModelFromJson(Map<String, dynamic> json) =>
    _QuizResultModel(
      id: json['id'] as String,
      examTitle: json['examTitle'] as String,
      dateTime: (json['dateTime'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      answered: (json['answered'] as num).toInt(),
      correct: (json['correct'] as num).toInt(),
      wrong: (json['wrong'] as num).toInt(),
      unanswered: (json['unanswered'] as num).toInt(),
      totalTimeSeconds: (json['totalTimeSeconds'] as num).toInt(),
      timeUsedSeconds: (json['timeUsedSeconds'] as num).toInt(),
      passingScore: (json['passingScore'] as num?)?.toInt() ?? 0,
      passed: json['passed'] as bool? ?? false,
      correctByCategory:
          (json['correctByCategory'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      totalByCategory:
          (json['totalByCategory'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
    );

Map<String, dynamic> _$QuizResultModelToJson(_QuizResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examTitle': instance.examTitle,
      'dateTime': instance.dateTime,
      'totalQuestions': instance.totalQuestions,
      'answered': instance.answered,
      'correct': instance.correct,
      'wrong': instance.wrong,
      'unanswered': instance.unanswered,
      'totalTimeSeconds': instance.totalTimeSeconds,
      'timeUsedSeconds': instance.timeUsedSeconds,
      'passingScore': instance.passingScore,
      'passed': instance.passed,
      'correctByCategory': instance.correctByCategory,
      'totalByCategory': instance.totalByCategory,
    };

_AnswerLogEntry _$AnswerLogEntryFromJson(Map<String, dynamic> json) =>
    _AnswerLogEntry(
      questionId: json['questionId'] as String,
      correct: json['correct'] as bool,
      dateTime: (json['dateTime'] as num).toInt(),
    );

Map<String, dynamic> _$AnswerLogEntryToJson(_AnswerLogEntry instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'correct': instance.correct,
      'dateTime': instance.dateTime,
    };
