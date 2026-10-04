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
    emit(
      state.copyWith(
        phase: QuizPhase.answering,
        questions: event.questions,
        mode: event.mode,
        examTitle: event.title,
        currentIndex: 0,
        selectedAnswers: const {},
        markedQuestions: const {},
        correctnessByQuestion: const {},
        remainingSeconds: event.examTimeSeconds ?? 0,
        examDurationSeconds: event.examTimeSeconds ?? 0,
        loadStatus: RequestStatus.success,
        selectionSerial: 0,
      ),
    );
  }

  void _onSelectAnswer(SelectAnswerEvent event, Emitter<QuizState> emit) {
    final question = state.currentQuestion;
    if (question == null || question.id != event.questionId) return;

    final isMulti = question.type == QuestionType.multipleChoice;
    final nextSelections = Map<String, Set<String>>.from(state.selectedAnswers);
    final current = Set<String>.from(state.selectionsOf(event.questionId));

    if (isMulti) {
      if (!current.remove(event.answerId)) {
        current.add(event.answerId);
      }
      nextSelections[event.questionId] = current;
    } else {
      nextSelections[event.questionId] = {event.answerId};
    }

    final nextCorrectness = Map<String, bool>.from(state.correctnessByQuestion);

    // Practice mode gives instant correctness feedback and feeds the mistakes log.
    if (state.isPractice) {
      final selection = nextSelections[event.questionId] ?? const <String>{};
      final isCorrect = question.isSelectionCorrect(selection);
      nextCorrectness[event.questionId] = isCorrect;
      final questionId = event.questionId;
      _recordAnswer(RecordAnswerParams(questionId: questionId, wasCorrect: isCorrect));
    }

    emit(
      state.copyWith(
        selectedAnswers: nextSelections,
        correctnessByQuestion: nextCorrectness,
        selectionSerial: state.selectionSerial + 1,
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
        outcome: null,
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
