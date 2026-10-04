import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/question_model.dart';
import 'quiz_event.dart';

class QuizState extends Equatable {
  const QuizState({
    this.phase = QuizPhase.loading,
    this.questions = const [],
    this.currentIndex = 0,
    this.mode = QuizMode.practice,
    this.selectedAnswers = const {},
    this.markedQuestions = const {},
    this.correctnessByQuestion = const {},
    this.remainingSeconds = 0,
    this.examDurationSeconds = 0,
    this.loadStatus = RequestStatus.init,
    this.examTitle,
    this.outcome,
    this.selectionSerial = 0,
  });

  final QuizPhase phase;
  final List<QuestionModel> questions;
  final int currentIndex;
  final QuizMode mode;
  final Map<String, Set<String>> selectedAnswers;
  final Set<String> markedQuestions;
  final Map<String, bool> correctnessByQuestion;
  final int remainingSeconds;

  /// Monotonic counter bumped on every answer tap, even when the selection map
  /// itself is unchanged, so side effects (SFX/TTS feedback) can react to
  /// repeated taps on the same answer.
  final int selectionSerial;

  /// The full exam duration set on load, kept so a retry restarts with a fresh
  /// timer instead of the remaining (possibly expired) time.
  final int examDurationSeconds;
  final RequestStatus loadStatus;
  final String? examTitle;
  final QuizOutcome? outcome;

  bool get isExam => mode == QuizMode.exam;
  bool get isPractice => mode == QuizMode.practice;
  bool get hasQuestions => questions.isNotEmpty;
  int get totalQuestions => questions.length;

  QuestionModel? get currentQuestion => hasQuestions ? questions[currentIndex] : null;

  Set<String> selectionsOf(String questionId) => selectedAnswers[questionId] ?? const {};

  bool isMarked(String questionId) => markedQuestions.contains(questionId);

  bool isCorrect(String questionId) => correctnessByQuestion[questionId] ?? false;

  /// Furthest index a user may reach. Questions unlock progressively: the
  /// first question that has not been answered correctly (and everything
  /// before it) stays reachable; later ones are locked until it is. In exam
  /// mode navigation is free.
  int get maxUnlockedIndex {
    if (questions.isEmpty) return 0;
    if (isExam) return totalQuestions - 1;
    for (var i = 0; i < questions.length; i++) {
      if (correctnessByQuestion[questions[i].id] != true) return i;
    }
    return totalQuestions - 1;
  }

  bool isQuestionUnlocked(int index) => index <= maxUnlockedIndex;

  @override
  List<Object?> get props => [
    phase,
    questions,
    currentIndex,
    mode,
    selectedAnswers,
    markedQuestions,
    correctnessByQuestion,
    remainingSeconds,
    examDurationSeconds,
    loadStatus,
    examTitle,
    outcome,
    selectionSerial,
  ];

  QuizState copyWith({
    QuizPhase? phase,
    List<QuestionModel>? questions,
    int? currentIndex,
    QuizMode? mode,
    Map<String, Set<String>>? selectedAnswers,
    Set<String>? markedQuestions,
    Map<String, bool>? correctnessByQuestion,
    int? remainingSeconds,
    int? examDurationSeconds,
    RequestStatus? loadStatus,
    String? examTitle,
    QuizOutcome? outcome,
    int? selectionSerial,
  }) {
    return QuizState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      mode: mode ?? this.mode,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      markedQuestions: markedQuestions ?? this.markedQuestions,
      correctnessByQuestion: correctnessByQuestion ?? this.correctnessByQuestion,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      examDurationSeconds: examDurationSeconds ?? this.examDurationSeconds,
      loadStatus: loadStatus ?? this.loadStatus,
      examTitle: examTitle ?? this.examTitle,
      outcome: outcome ?? this.outcome,
      selectionSerial: selectionSerial ?? this.selectionSerial,
    );
  }
}
