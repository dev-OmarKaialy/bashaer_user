import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/request_status.dart';
import '../../data/models/stats_model.dart';
import '../../domain/usecases/clear_bookmarks_usecase.dart';
import '../../domain/usecases/clear_statistics_usecase.dart';
import '../../domain/usecases/get_all_questions_usecase.dart';
import '../../domain/usecases/get_answer_log_usecase.dart';
import '../../domain/usecases/get_bookmarked_ids_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_results_usecase.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/save_result_usecase.dart';
import '../../domain/usecases/sync_question_bank_usecase.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import 'progress_event.dart';
import 'progress_state.dart';

/// App-level state shared by every screen: bookmarks, mistakes, exam history
/// and statistics. One singleton instance lives for the whole app lifetime.
@lazySingleton
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  ProgressBloc({
    required GetCategoriesUsecase getCategories,
    required GetAllQuestionsUsecase getAllQuestions,
    required GetBookmarkedIdsUsecase getBookmarkedIds,
    required ToggleBookmarkUsecase toggleBookmark,
    required GetAnswerLogUsecase getAnswerLog,
    required GetResultsUsecase getResults,
    required GetStatsUsecase getStats,
    required SaveResultUsecase saveResult,
    required SyncQuestionBankUsecase syncQuestionBank,
    required ClearStatisticsUsecase clearStatistics,
    required ClearBookmarksUsecase clearBookmarks,
  }) : _getCategories = getCategories,
       _getAllQuestions = getAllQuestions,
       _getBookmarkedIds = getBookmarkedIds,
       _toggleBookmark = toggleBookmark,
       _getAnswerLog = getAnswerLog,
       _getResults = getResults,
       _getStats = getStats,
       _saveResult = saveResult,
       _syncQuestionBank = syncQuestionBank,
       _clearStatistics = clearStatistics,
       _clearBookmarks = clearBookmarks,
       super(const ProgressState()) {
    on<LoadProgressEvent>(_onLoad);
    on<ToggleBookmarkFromProgress>(_onToggleBookmark);
    on<SaveResultProgressEvent>(_onSaveResult);
    on<RefreshBankEvent>(_onRefreshBank);
    on<ClearStatisticsEvent>(_onClearStatistics);
    on<ClearBookmarksEvent>(_onClearBookmarks);
  }

  final GetCategoriesUsecase _getCategories;
  final GetAllQuestionsUsecase _getAllQuestions;
  final GetBookmarkedIdsUsecase _getBookmarkedIds;
  final ToggleBookmarkUsecase _toggleBookmark;
  final GetAnswerLogUsecase _getAnswerLog;
  final GetResultsUsecase _getResults;
  final GetStatsUsecase _getStats;
  final SaveResultUsecase _saveResult;
  final SyncQuestionBankUsecase _syncQuestionBank;
  final ClearStatisticsUsecase _clearStatistics;
  final ClearBookmarksUsecase _clearBookmarks;

  Future<void> _onLoad(LoadProgressEvent event, Emitter<ProgressState> emit) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final categories = await _getCategories(NoParams());
    final questions = await _getAllQuestions(NoParams());
    final bookmarks = await _getBookmarkedIds(NoParams());
    final log = await _getAnswerLog(NoParams());
    final results = await _getResults(NoParams());
    if (isClosed) return;

    if (categories.isLeft() || questions.isLeft()) {
      emit(state.copyWith(status: RequestStatus.failed));
      return;
    }

    final stats = await _statsOrNull();
    if (isClosed) return;

    emit(
      state.copyWith(
        status: RequestStatus.success,
        categories: categories.getOrElse(() => const []),
        questions: questions.getOrElse(() => const []),
        bookmarkedIds: bookmarks.getOrElse(() => const {}),
        answerLog: log.getOrElse(() => const []),
        results: results.getOrElse(() => const []),
        stats: stats,
      ),
    );
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkFromProgress event,
    Emitter<ProgressState> emit,
  ) async {
    final result = await _toggleBookmark(ToggleBookmarkParams(questionId: event.questionId));
    if (isClosed) return;
    final updated = result.fold<Set<String>?>((failure) => null, (value) => value);
    if (updated == null) return;

    emit(state.copyWith(bookmarkedIds: updated));
    final stats = await _statsOrNull();
    if (isClosed) return;
    emit(state.copyWith(bookmarkedIds: updated, stats: stats));
  }

  Future<void> _onSaveResult(SaveResultProgressEvent event, Emitter<ProgressState> emit) async {
    final saved = await _saveResult(SaveResultParams(result: event.result));
    if (isClosed) return;
    if (saved.isLeft()) return;

    final allResults = [...state.results, event.result];
    emit(state.copyWith(results: allResults));
    final stats = await _statsOrNull();
    if (isClosed) return;
    emit(state.copyWith(results: allResults, stats: stats));
  }

  /// Pulls a fresh bank from Firestore, then reloads everything derived from it.
  Future<void> _onRefreshBank(RefreshBankEvent event, Emitter<ProgressState> emit) async {
    if (state.refreshStatus.isLoading) return;

    emit(state.copyWith(refreshStatus: RequestStatus.loading));
    final result = await _syncQuestionBank(const SyncQuestionBankParams());
    if (isClosed) return;

    if (result.isLeft()) {
      emit(state.copyWith(refreshStatus: RequestStatus.failed));
      return;
    }
    emit(state.copyWith(refreshStatus: RequestStatus.success));
    await _onLoad(const LoadProgressEvent(), emit);
  }

  Future<void> _onClearStatistics(ClearStatisticsEvent event, Emitter<ProgressState> emit) async {
    if (state.clearStatus.isLoading) return;

    emit(state.copyWith(clearStatus: RequestStatus.loading));
    final result = await _clearStatistics(NoParams());
    if (isClosed) return;

    if (result.isLeft()) {
      emit(state.copyWith(clearStatus: RequestStatus.failed));
      return;
    }
    final stats = await _statsOrNull();
    if (isClosed) return;
    emit(
      state.copyWith(
        clearStatus: RequestStatus.success,
        answerLog: const [],
        results: const [],
        stats: stats,
      ),
    );
  }

  Future<void> _onClearBookmarks(ClearBookmarksEvent event, Emitter<ProgressState> emit) async {
    if (state.clearStatus.isLoading) return;

    emit(state.copyWith(clearStatus: RequestStatus.loading));
    final result = await _clearBookmarks(NoParams());
    if (isClosed) return;

    if (result.isLeft()) {
      emit(state.copyWith(clearStatus: RequestStatus.failed));
      return;
    }
    final stats = await _statsOrNull();
    if (isClosed) return;
    emit(state.copyWith(clearStatus: RequestStatus.success, bookmarkedIds: const {}, stats: stats));
  }

  /// Recomputes the aggregated statistics after progress changed. Returns
  /// null (the last stats stay in place) when the computation fails.
  Future<StatsModel?> _statsOrNull() async {
    final result = await _getStats(NoParams());
    if (isClosed) return null;
    return result.fold((failure) => null, (stats) => stats);
  }
}
