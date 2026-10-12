import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/request_status.dart';
import '../../data/models/training_session_model.dart';
import '../../domain/usecases/finish_session_usecase.dart';
import '../../domain/usecases/get_active_session_usecase.dart';
import '../../domain/usecases/get_session_history_usecase.dart';
import '../../domain/usecases/save_active_session_usecase.dart';
import 'training_session_event.dart';
import 'training_session_state.dart';

/// Owns the training session: a run from the chosen category to the last one,
/// in order, spanning several quiz screens. One singleton lives for the app
/// lifetime; every change is persisted so an interrupted session still reaches
/// the history on the next launch (it is not resumed).
@lazySingleton
class TrainingSessionBloc extends Bloc<TrainingSessionEvent, TrainingSessionState> {
  TrainingSessionBloc({
    required GetActiveSessionUsecase getActiveSession,
    required SaveActiveSessionUsecase saveActiveSession,
    required FinishSessionUsecase finishSession,
    required GetSessionHistoryUsecase getSessionHistory,
  }) : _getActiveSession = getActiveSession,
       _saveActiveSession = saveActiveSession,
       _finishSession = finishSession,
       _getSessionHistory = getSessionHistory,
       super(const TrainingSessionState()) {
    on<LoadTrainingSessionEvent>(_onLoad);
    on<StartTrainingSessionEvent>(_onStart);
    on<RecordAttemptTrainingSessionEvent>(_onRecordAttempt);
    on<CompleteCategoryTrainingSessionEvent>(_onCompleteCategory);
    on<StopTrainingSessionEvent>(_onStop);
  }

  final GetActiveSessionUsecase _getActiveSession;
  final SaveActiveSessionUsecase _saveActiveSession;
  final FinishSessionUsecase _finishSession;
  final GetSessionHistoryUsecase _getSessionHistory;

  Future<void> _onLoad(LoadTrainingSessionEvent event, Emitter<TrainingSessionState> emit) async {
    emit(state.copyWith(loadStatus: RequestStatus.loading));
    final active = await _getActiveSession(NoParams());
    final history = await _getSessionHistory(NoParams());
    if (isClosed) return;

    if (active.isLeft() || history.isLeft()) {
      emit(state.copyWith(loadStatus: RequestStatus.failed));
      return;
    }
    var past = history.getOrElse(() => const <TrainingSessionModel>[]);
    // Sessions are not resumed: one left unfinished (the app was closed half
    // way) is archived as stopped, so its points still reach the history.
    final leftover = active.getOrElse(() => null);
    if (leftover != null) {
      final stopped = leftover.copyWith(
        status: TrainingSessionStatus.stopped,
        endedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _finishSession(FinishSessionParams(session: stopped));
      if (isClosed) return;
      if (stopped.totalAttempts > 0) past = [stopped, ...past];
    }
    emit(
      state.copyWith(loadStatus: RequestStatus.success, clearSession: true, history: past),
    );
  }

  Future<void> _onStart(StartTrainingSessionEvent event, Emitter<TrainingSessionState> emit) async {
    if (state.startStatus.isLoading) return;
    if (event.categoryIds.isEmpty) {
      emit(state.copyWith(startStatus: RequestStatus.failed));
      return;
    }

    emit(state.copyWith(startStatus: RequestStatus.loading));
    final previous = state.session;
    if (previous != null) {
      await _end(previous.copyWith(status: TrainingSessionStatus.stopped), emit);
      if (isClosed) return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final session = TrainingSessionModel(
      id: now.toString(),
      startedAt: now,
      categoryIds: event.categoryIds,
    );
    final saved = await _saveActiveSession(SaveActiveSessionParams(session: session));
    if (isClosed) return;

    saved.fold(
      (failure) => emit(state.copyWith(startStatus: RequestStatus.failed)),
      (_) => emit(
        state.copyWith(startStatus: RequestStatus.success, session: session, streak: 0),
      ),
    );
  }

  Future<void> _onRecordAttempt(
    RecordAttemptTrainingSessionEvent event,
    Emitter<TrainingSessionState> emit,
  ) async {
    final session = state.session;
    if (session == null) return;

    final next = session.copyWith(
      points: event.points,
      currentCorrectAttempts: event.correctAttempts,
      currentTotalAttempts: event.totalAttempts,
      solvedQuestionIds: event.solvedQuestionIds,
    );
    emit(state.copyWith(session: next, streak: event.streak));
    await _saveActiveSession(SaveActiveSessionParams(session: next));
  }

  Future<void> _onCompleteCategory(
    CompleteCategoryTrainingSessionEvent event,
    Emitter<TrainingSessionState> emit,
  ) async {
    final session = state.session;
    final categoryId = session?.currentCategoryId;
    if (session == null || categoryId == null) return;

    final round = CategoryRoundResult(
      categoryId: categoryId,
      categoryName: event.categoryName,
      correctAttempts: event.correctAttempts,
      totalAttempts: event.totalAttempts,
    );
    final next = session.copyWith(
      points: event.points,
      currentCorrectAttempts: 0,
      currentTotalAttempts: 0,
      solvedQuestionIds: const [],
      categoryResults: [...session.categoryResults, round],
    );

    if (session.isLastCategory) {
      await _end(next.copyWith(status: TrainingSessionStatus.completed), emit);
      return;
    }

    final advanced = next.copyWith(currentCategoryIndex: session.currentCategoryIndex + 1);
    emit(state.copyWith(session: advanced));
    await _saveActiveSession(SaveActiveSessionParams(session: advanced));
  }

  Future<void> _onStop(StopTrainingSessionEvent event, Emitter<TrainingSessionState> emit) async {
    final session = state.session;
    if (session == null) return;
    await _end(session.copyWith(status: TrainingSessionStatus.stopped), emit);
  }

  /// Stamps the end time on [ended], moves it to the history and clears the
  /// active session. A session without any attempt is not archived.
  Future<void> _end(TrainingSessionModel ended, Emitter<TrainingSessionState> emit) async {
    final finished = ended.copyWith(endedAt: DateTime.now().millisecondsSinceEpoch);
    emit(
      state.copyWith(
        clearSession: true,
        finishedSession: finished,
        history: finished.totalAttempts > 0 ? [finished, ...state.history] : state.history,
      ),
    );
    await _finishSession(FinishSessionParams(session: finished));
  }
}
