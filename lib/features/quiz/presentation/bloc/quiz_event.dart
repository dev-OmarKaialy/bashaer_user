import 'package:equatable/equatable.dart';

import '../../data/models/question_model.dart';

/// What the quiz is doing right now.
enum QuizPhase { loading, answering, results }

/// The kind of quiz session.
enum QuizMode { practice, exam }

sealed class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

final class LoadQuizEvent extends QuizEvent {
  const LoadQuizEvent({
    required this.questions,
    required this.mode,
    this.examTimeSeconds,
    this.title,
  });

  final List<QuestionModel> questions;
  final QuizMode mode;
  final int? examTimeSeconds;
  final String? title;

  @override
  List<Object?> get props => [questions, mode, examTimeSeconds, title];
}

final class SelectAnswerEvent extends QuizEvent {
  const SelectAnswerEvent({required this.questionId, required this.answerId});

  final String questionId;
  final String answerId;

  @override
  List<Object?> get props => [questionId, answerId];
}

final class NextQuestionEvent extends QuizEvent {
  const NextQuestionEvent();
}

final class PreviousQuestionEvent extends QuizEvent {
  const PreviousQuestionEvent();
}

final class GoToQuestionEvent extends QuizEvent {
  const GoToQuestionEvent({required this.index});

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ToggleMarkEvent extends QuizEvent {
  const ToggleMarkEvent({required this.questionId});

  final String questionId;

  @override
  List<Object?> get props => [questionId];
}

final class TickEvent extends QuizEvent {
  const TickEvent();
}

final class SubmitQuizEvent extends QuizEvent {
  const SubmitQuizEvent();
}

final class RestartQuizEvent extends QuizEvent {
  const RestartQuizEvent();
}

/// Marker result data computed at submission time.
class QuizOutcome {
  const QuizOutcome({
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.answered,
  });

  final int correct;
  final int wrong;
  final int unanswered;
  final int answered;
}
