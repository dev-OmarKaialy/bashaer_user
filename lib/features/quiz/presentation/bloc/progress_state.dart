import 'package:equatable/equatable.dart';

import '../../../../core/utils/request_status.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/models/stats_model.dart';

class ProgressState extends Equatable {
  const ProgressState({
    this.status = RequestStatus.init,
    this.refreshStatus = RequestStatus.init,
    this.clearStatus = RequestStatus.init,
    this.categories = const [],
    this.questions = const [],
    this.bookmarkedIds = const {},
    this.answerLog = const [],
    this.results = const [],
    this.stats,
  });

  final RequestStatus status;

  /// Manual "update data from server" run, triggered from the drawer.
  final RequestStatus refreshStatus;

  /// Clearing statistics or bookmarks from the drawer.
  final RequestStatus clearStatus;
  final List<CategoryModel> categories;
  final List<QuestionModel> questions;
  final Set<String> bookmarkedIds;
  final List<AnswerLogEntry> answerLog;
  final List<QuizResultModel> results;
  final StatsModel? stats;

  List<CategoryModel> categoriesWithCount() {
    final list = List<CategoryModel>.from(categories);
    if (list.isEmpty) return list;
    final counts = <String, int>{};
    for (final q in questions) {
      counts.update(q.categoryId, (v) => v + 1, ifAbsent: () => 1);
    }
    return list.map((c) => c.copyWith(questionCount: counts[c.id] ?? 0)).toList();
  }

  @override
  List<Object?> get props => [
    status,
    refreshStatus,
    clearStatus,
    categories,
    questions,
    bookmarkedIds,
    answerLog,
    results,
    stats,
  ];

  ProgressState copyWith({
    RequestStatus? status,
    RequestStatus? refreshStatus,
    RequestStatus? clearStatus,
    List<CategoryModel>? categories,
    List<QuestionModel>? questions,
    Set<String>? bookmarkedIds,
    List<AnswerLogEntry>? answerLog,
    List<QuizResultModel>? results,
    StatsModel? stats,
  }) {
    return ProgressState(
      status: status ?? this.status,
      refreshStatus: refreshStatus ?? this.refreshStatus,
      clearStatus: clearStatus ?? this.clearStatus,
      categories: categories ?? this.categories,
      questions: questions ?? this.questions,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      answerLog: answerLog ?? this.answerLog,
      results: results ?? this.results,
      stats: stats ?? this.stats,
    );
  }
}
