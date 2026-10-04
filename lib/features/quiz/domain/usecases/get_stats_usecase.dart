import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/models/stats_model.dart';
import '../../domain/repositories/quiz_repository.dart';

/// Builds the overall study statistics from the question bank, the answer log
/// and the saved exam results.
@injectable
class GetStatsUsecase implements UseCase<StatsModel, NoParams> {
  GetStatsUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, StatsModel>> call(NoParams params) => _compute();

  Future<Either<Failure, StatsModel>> _compute() async {
    try {
      final questionsResult = await _repository.getAllQuestions();
      final logResult = await _repository.getAnswerLog();
      final resultsResult = await _repository.getResults();
      final bookmarksResult = await _repository.getBookmarkedQuestionIds();

      final questions = questionsResult.fold((_) => <QuestionModel>[], (value) => value);
      final log = logResult.fold((_) => <AnswerLogEntry>[], (value) => value);
      final results = resultsResult.fold((_) => <QuizResultModel>[], (value) => value);

      final questionByCategory = <String, QuestionModel>{};
      for (final q in questions) {
        questionByCategory[q.id] = q;
      }

      final categoryStats = <String, CategoryStat>{};
      var totalCorrect = 0;
      var totalWrong = 0;
      for (final entry in log) {
        final categoryId = questionByCategory[entry.questionId]?.categoryId;
        final stat = categoryStats.putIfAbsent(categoryId ?? 'other', () => const CategoryStat());
        categoryStats[categoryId ?? 'other'] = stat.copyWith(
          answered: stat.answered + 1,
          correct: stat.correct + (entry.correct ? 1 : 0),
          mistakes: stat.mistakes + (entry.correct ? 0 : 1),
        );
        if (entry.correct) {
          totalCorrect++;
        } else {
          totalWrong++;
        }
      }

      final examScores = results.map((r) => r.accuracy).toList();
      final best = examScores.isEmpty ? 0 : examScores.reduce((a, b) => a > b ? a : b);
      final average = examScores.isEmpty
          ? 0.0
          : examScores.reduce((a, b) => a + b) / examScores.length;

      return Right(
        StatsModel(
          totalAnswered: totalCorrect + totalWrong,
          totalCorrect: totalCorrect,
          totalWrong: totalWrong,
          examsTaken: results.length,
          bestExamScore: best.round(),
          averageExamScore: average,
          accuracy: totalCorrect + totalWrong == 0
              ? 0
              : (totalCorrect / (totalCorrect + totalWrong)) * 100,
          categoryStats: categoryStats,
          bookmarkedCount: bookmarksResult.fold((_) => 0, (value) => value.length),
          mistakeCount: totalWrong,
        ),
      );
    } catch (e) {
      return const Left(ServerFailure(message: ''));
    }
  }
}
