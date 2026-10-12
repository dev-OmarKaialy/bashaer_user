import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/question_model.dart';
import '../../domain/usecases/record_answer_usecase.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

/// The quiz engine: owns the question flow, selections, marking, exam timer,
/// immediate practice feedback and final result computation.
@injectable
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc({required RecordAnswerUsecase recordAnswer})
    : _recordAnswer = recordAnswer,
      super(const QuizState()) {
    on<LoadQuizEvent>(_onLoad);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<NextQuestionEvent>(_onNext);
    on<PreviousQuestionEvent>(_onPrevious);
    on<GoToQuestionEvent>(_onGoTo);
    on<ToggleMarkEvent>(_onToggleMark);
    on<TickEvent>(_onTick);
    on<SubmitQuizEvent>(_onSubmit);
    on<RestartQuizEvent>(_onRestart);
  }

  final RecordAnswerUsecase _recordAnswer;

  Future<void> _onLoad(LoadQuizEvent event, Emitter<QuizState> emit) async {
    if (event.questions.isEmpty) {
      emit(state.copyWith(loadStatus: RequestStatus.failed));
      return;
    }

    // A resumed training session restores the questions already solved, and
    // continues from the first one that is not.
    final solved = event.solvedQuestionIds.toSet();
    final selectedAnswers = {
      for (final q in event.questions)
        if (solved.contains(q.id)) q.id: q.correctAnswerIds.toSet(),
    };
    final correctness = {for (final id in selectedAnswers.keys) id: true};
    final firstUnsolved = event.questions.indexWhere((q) => !solved.contains(q.id));

    emit(
      state.copyWith(
        phase: QuizPhase.answering,
        questions: event.questions,
        mode: event.mode,
        examTitle: event.title,
        currentIndex: firstUnsolved < 0 ? 0 : firstUnsolved,
        selectedAnswers: selectedAnswers,
        markedQuestions: const {},
        correctnessByQuestion: correctness,
        remainingSeconds: event.examTimeSeconds ?? 0,
        examDurationSeconds: event.examTimeSeconds ?? 0,
        loadStatus: RequestStatus.success,
        selectionSerial: 0,
        points: event.initialPoints,
        correctAttempts: event.initialCorrectAttempts,
        totalAttempts: event.initialTotalAttempts,
        attemptSerial: 0,
        streak: event.initialStreak,
      ),
    );
  }

  void _onSelectAnswer(SelectAnswerEvent event, Emitter<QuizState> emit) {
    final question = state.currentQuestion;
    if (question == null || question.id != event.questionId) return;
    // A solved practice question stays solved, so its points can't be farmed.
    if (state.isPractice && state.isCorrect(question.id)) return;

    final isMulti = question.type == QuestionType.multipleChoice;
    final nextSelections = Map<String, Set<String>>.from(state.selectedAnswers);
    final previous = state.selectionsOf(event.questionId);
    final current = Set<String>.from(previous);

    if (isMulti) {
      if (!current.remove(event.answerId)) {
        current.add(event.answerId);
      }
      nextSelections[event.questionId] = current;
    } else {
      nextSelections[event.questionId] = {event.answerId};
    }

    final nextCorrectness = Map<String, bool>.from(state.correctnessByQuestion);
    var points = state.points;
    var correctAttempts = state.correctAttempts;
    var totalAttempts = state.totalAttempts;
    var attemptSerial = state.attemptSerial;
    var streak = state.streak;

    // Practice mode gives instant correctness feedback and feeds the mistakes log.
    if (state.isPractice) {
      final selection = nextSelections[event.questionId] ?? const <String>{};
      final isCorrect = question.isSelectionCorrect(selection);
      nextCorrectness[event.questionId] = isCorrect;
      final questionId = event.questionId;
      _recordAnswer(RecordAnswerParams(questionId: questionId, wasCorrect: isCorrect));

      // An attempt is a complete answer (as many options as correct ones)
      // that differs from the previous one: +1 when right, −1 when wrong.
      final isComplete = selection.length == question.correctAnswerIds.toSet().length;
      final isRepeat = selection.length == previous.length && selection.containsAll(previous);
      if (isComplete && !isRepeat) {
        totalAttempts++;
        if (isCorrect) correctAttempts++;
        points = math.max(0, points + (isCorrect ? 1 : -1));
        streak = isCorrect ? streak + 1 : 0;
        attemptSerial++;
      }
    }

    emit(
      state.copyWith(
        selectedAnswers: nextSelections,
        correctnessByQuestion: nextCorrectness,
        selectionSerial: state.selectionSerial + 1,
        points: points,
        correctAttempts: correctAttempts,
        totalAttempts: totalAttempts,
        attemptSerial: attemptSerial,
        streak: streak,
      ),
    );
  }

  void _onNext(NextQuestionEvent event, Emitter<QuizState> emit) {
    if (!state.hasQuestions || state.currentIndex >= state.totalQuestions - 1) return;
    if (state.currentIndex >= state.maxUnlockedIndex) return;
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  void _onPrevious(PreviousQuestionEvent event, Emitter<QuizState> emit) {
    if (state.currentIndex <= 0) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  void _onGoTo(GoToQuestionEvent event, Emitter<QuizState> emit) {
    if (event.index < 0 || event.index >= state.totalQuestions) return;
    if (!state.isQuestionUnlocked(event.index)) return;
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onToggleMark(ToggleMarkEvent event, Emitter<QuizState> emit) {
    final next = Set<String>.from(state.markedQuestions);
    if (!next.remove(event.questionId)) next.add(event.questionId);
    emit(state.copyWith(markedQuestions: next));
  }

  void _onTick(TickEvent event, Emitter<QuizState> emit) {
    if (!state.isExam || state.phase != QuizPhase.answering) return;
    if (state.remainingSeconds <= 1) {
      add(const SubmitQuizEvent());
      return;
    }
    emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
  }

  void _onSubmit(SubmitQuizEvent event, Emitter<QuizState> emit) {
    if (state.phase == QuizPhase.results) return;

    var correct = 0;
    var wrong = 0;
    var answered = 0;
    for (final q in state.questions) {
      final selection = state.selectionsOf(q.id);
      if (selection.isEmpty) continue;
      answered++;
      if (q.isSelectionCorrect(selection)) {
        correct++;
      } else {
        wrong++;
      }
    }

    final unanswered = state.totalQuestions - answered;
    final outcome = QuizOutcome(
      correct: correct,
      wrong: wrong,
      unanswered: unanswered,
      answered: answered,
    );

    emit(state.copyWith(phase: QuizPhase.results, outcome: outcome));
  }

  Future<void> _onRestart(RestartQuizEvent event, Emitter<QuizState> emit) async {
    final questions = state.questions;
    final mode = state.mode;
    final examTime = state.mode == QuizMode.exam ? state.examDurationSeconds : null;
    emit(
      state.copyWith(
        phase: QuizPhase.loading,
        questions: const [],
        selectedAnswers: const {},
        markedQuestions: const {},
        correctnessByQuestion: const {},
        remainingSeconds: 0,
        clearOutcome: true,
      ),
    );
    add(
      LoadQuizEvent(
        questions: questions,
        mode: mode,
        examTimeSeconds: examTime,
        title: state.examTitle,
      ),
    );
  }
}
