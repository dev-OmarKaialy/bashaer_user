import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/hive/hive_boxes.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';

/// Device-local storage, backed by Hive.
///
/// Holds two unrelated things: the question bank cached from Firestore on every
/// successful startup sync, and the study progress (bookmarks, answer log,
/// results) that the statistics are derived from.
abstract class QuizLocalDatasource {
  bool hasCachedBank();
  Future<List<CategoryModel>> getCategories();
  Future<List<QuestionModel>> getQuestions();
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<void> cacheQuestions(List<QuestionModel> questions);
  Future<Set<String>> getBookmarkedQuestionIds();
  Set<String> toggleBookmarkLocally(String questionId, Set<String> current);
  Future<void> saveBookmarks(Set<String> bookmarks);
  Future<List<AnswerLogEntry>> getAnswerLog();
  Future<void> appendAnswerLog(AnswerLogEntry entry);
  Future<List<QuizResultModel>> getResults();
  Future<void> saveResult(QuizResultModel result);

  /// Wipes the answer log and exam results. Bookmarks are left alone — they are
  /// the student's saved questions, not statistics.
  Future<void> clearStatistics();

  /// Wipes the saved (bookmarked) questions, leaving statistics alone.
  Future<void> clearBookmarks();
}

@Injectable(as: QuizLocalDatasource)
class QuizLocalDatasourceImpl implements QuizLocalDatasource {
  QuizLocalDatasourceImpl(this._hive);

  final HiveService _hive;

  Box<dynamic> get _bank => _hive.quizBank;

  Box<dynamic> get _progress => _hive.quizProgress;

  /// Cached rows, or an empty list when nothing usable is stored.
  ///
  /// Reads are filtered by type rather than cast so that a cache written by an
  /// older adapter degrades to empty instead of throwing.
  List<T> _cached<T>(String key) {
    final stored = _bank.get(key);
    if (stored is! List) return const [];
    return stored.whereType<T>().toList();
  }

  @override
  bool hasCachedBank() {
    return _cached<CategoryModel>(QuizBankKeys.categories).isNotEmpty &&
        _cached<QuestionModel>(QuizBankKeys.questions).isNotEmpty;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final cached = _cached<CategoryModel>(QuizBankKeys.categories);
    if (cached.isEmpty) {
      throw const DatabaseFailure(message: 'Question bank is not cached yet');
    }
    return cached;
  }

  @override
  Future<List<QuestionModel>> getQuestions() async {
    final cached = _cached<QuestionModel>(QuizBankKeys.questions);
    if (cached.isEmpty) {
      throw const DatabaseFailure(message: 'Question bank is not cached yet');
    }
    return cached;
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) {
    return _bank.putAll({
      QuizBankKeys.categories: categories,
      QuizBankKeys.fetchedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> cacheQuestions(List<QuestionModel> questions) {
    return _bank.putAll({
      QuizBankKeys.questions: questions,
      QuizBankKeys.fetchedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<Set<String>> getBookmarkedQuestionIds() async {
    final stored = _progress.get(QuizProgressKeys.bookmarks);
    if (stored is! List) return <String>{};
    return stored.map((e) => e.toString()).toSet();
  }

  @override
  Set<String> toggleBookmarkLocally(String questionId, Set<String> current) {
    final next = {...current};
    if (!next.remove(questionId)) {
      next.add(questionId);
    }
    return next;
  }

  @override
  Future<void> saveBookmarks(Set<String> bookmarks) {
    return _progress.put(QuizProgressKeys.bookmarks, bookmarks.toList());
  }

  @override
  Future<List<AnswerLogEntry>> getAnswerLog() async {
    final stored = _progress.get(QuizProgressKeys.answerLog);
    if (stored is! List) return const [];
    return stored.whereType<AnswerLogEntry>().toList();
  }

  @override
  Future<void> appendAnswerLog(AnswerLogEntry entry) async {
    final existing = await getAnswerLog();
    await _progress.put(QuizProgressKeys.answerLog, [...existing, entry]);
  }

  @override
  Future<List<QuizResultModel>> getResults() async {
    final stored = _progress.get(QuizProgressKeys.results);
    if (stored is! List) return const [];
    return stored.whereType<QuizResultModel>().toList();
  }

  @override
  Future<void> saveResult(QuizResultModel result) async {
    final existing = await getResults();
    await _progress.put(QuizProgressKeys.results, [result, ...existing]);
  }

  @override
  Future<void> clearStatistics() async {
    await _progress.delete(QuizProgressKeys.answerLog);
    await _progress.delete(QuizProgressKeys.results);
  }

  @override
  Future<void> clearBookmarks() {
    return _progress.delete(QuizProgressKeys.bookmarks);
  }
}
