import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../../../core/unified_api/error/error_handeler.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../../data/datasources/quiz_local_datasource.dart';
import '../../data/datasources/quiz_media_cache.dart';
import '../../data/datasources/quiz_remote_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@Injectable(as: QuizRepository)
class QuizRepositoryImpl with HandlingException implements QuizRepository {
  QuizRepositoryImpl(this._remoteDatasource, this._localDatasource, this._mediaCache);

  final QuizRemoteDatasource _remoteDatasource;
  final QuizLocalDatasource _localDatasource;
  final QuizMediaCache _mediaCache;

  /// Pulls the bank from Firestore once at startup, writes it to Hive, then
  /// downloads every question/answer image and optional audio for offline exams.
  ///
  /// A failed network/server call still succeeds when a previous sync left a
  /// usable cache on the device. First launch with no network and no cache
  /// fails so the bootstrap screen can retry.
  /// Share of the bar each stage owns; media downloads take the rest.
  static const _categoriesDone = 0.15;
  static const _questionsDone = 0.35;
  static const _cachedDone = 0.45;

  @override
  Future<Either<Failure, void>> syncQuestionBank({void Function(double progress)? onProgress}) {
    return wrapHandling(
      tryCall: () async {
        try {
          final categories = await _remoteDatasource.getCategories();
          onProgress?.call(_categoriesDone);
          final questions = await _remoteDatasource.getQuestions();
          onProgress?.call(_questionsDone);
          if (categories.isEmpty || questions.isEmpty) {
            throw const ServerFailure(
              message: 'Firestore returned an empty question bank',
              statusCode: ResponseCode.DEFAULT,
            );
          }
          await _localDatasource.cacheCategories(categories);
          await _localDatasource.cacheQuestions(questions);
          onProgress?.call(_cachedDone);
          await _cacheMedia(questions, onProgress);
          return;
        } catch (e) {
          if (_localDatasource.hasCachedBank()) {
            log('Firestore sync failed ($e); using the Hive question bank.'.logYellow);
            // Still try to fill any missing local media files from the cached URLs.
            onProgress?.call(_cachedDone);
            final cached = await _localDatasource.getQuestions();
            await _cacheMedia(cached, onProgress);
            return;
          }
          rethrow;
        }
      },
    );
  }

  Future<void> _cacheMedia(
    List<QuestionModel> questions,
    void Function(double progress)? onProgress,
  ) async {
    final urls = QuizMediaCache.urlsFromQuestions(questions);
    if (urls.isEmpty) {
      await _mediaCache.warm();
      onProgress?.call(1);
      return;
    }
    await _mediaCache.cacheUrls(
      urls,
      onProgress: (done, total) {
        if (total <= 0) {
          onProgress?.call(1);
          return;
        }
        onProgress?.call(_cachedDone + (1 - _cachedDone) * (done / total));
      },
    );
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() {
    return wrapHandling(tryCall: () => _localDatasource.getCategories());
  }

  @override
  Future<Either<Failure, List<QuestionModel>>> getAllQuestions() {
    return wrapHandling(tryCall: () => _localDatasource.getQuestions());
  }

  @override
  Future<Either<Failure, Set<String>>> getBookmarkedQuestionIds() {
    return wrapHandling(tryCall: () => _localDatasource.getBookmarkedQuestionIds());
  }

  @override
  Future<Either<Failure, Set<String>>> toggleBookmark(String questionId) {
    return wrapHandling(
      tryCall: () async {
        final current = await _localDatasource.getBookmarkedQuestionIds();
        final next = _localDatasource.toggleBookmarkLocally(questionId, current);
        await _localDatasource.saveBookmarks(next);
        return next;
      },
    );
  }

  @override
  Future<Either<Failure, List<AnswerLogEntry>>> getAnswerLog() {
    return wrapHandling(tryCall: () => _localDatasource.getAnswerLog());
  }

  @override
  Future<Either<Failure, void>> recordAnswer(String questionId, bool wasCorrect) {
    return wrapHandling(
      tryCall: () => _localDatasource.appendAnswerLog(
        AnswerLogEntry(
          questionId: questionId,
          correct: wasCorrect,
          dateTime: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, List<QuizResultModel>>> getResults() {
    return wrapHandling(tryCall: () => _localDatasource.getResults());
  }

  @override
  Future<Either<Failure, void>> saveResult(QuizResultModel result) {
    return wrapHandling(tryCall: () => _localDatasource.saveResult(result));
  }

  @override
  Future<Either<Failure, void>> clearStatistics() {
    return wrapHandling(tryCall: () => _localDatasource.clearStatistics());
  }

  @override
  Future<Either<Failure, void>> clearBookmarks() {
    return wrapHandling(tryCall: () => _localDatasource.clearBookmarks());
  }
}
