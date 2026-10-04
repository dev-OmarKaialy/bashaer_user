import 'package:dartz/dartz.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';

/// Contract for the quiz question bank and user progress storage.
abstract class QuizRepository {
  /// Fetches the bank from Firestore and caches it in Hive.
  ///
  /// [onProgress] reports completion in the 0–1 range as the stages finish
  /// (categories, questions, local write, then media downloads), so the splash
  /// can show a real progress bar.
  Future<Either<Failure, void>> syncQuestionBank({void Function(double progress)? onProgress});

  Future<Either<Failure, List<CategoryModel>>> getCategories();
  Future<Either<Failure, List<QuestionModel>>> getAllQuestions();
  Future<Either<Failure, Set<String>>> getBookmarkedQuestionIds();
  Future<Either<Failure, Set<String>>> toggleBookmark(String questionId);
  Future<Either<Failure, List<AnswerLogEntry>>> getAnswerLog();
  Future<Either<Failure, void>> recordAnswer(String questionId, bool wasCorrect);
  Future<Either<Failure, List<QuizResultModel>>> getResults();
  Future<Either<Failure, void>> saveResult(QuizResultModel result);

  /// Clears the answer log and exam results, keeping bookmarks.
  Future<Either<Failure, void>> clearStatistics();

  /// Clears the bookmarked questions, keeping statistics.
  Future<Either<Failure, void>> clearBookmarks();
}
