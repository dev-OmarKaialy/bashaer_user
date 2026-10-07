import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/question_model.dart';
import '../repositories/quiz_repository.dart';

/// The free-trial slice of the bank: the first [questionCount] questions in the
/// order the bank was cached (sorted by `qid`), so the trial is the same on
/// every device.
@lazySingleton
class GetTrialQuestionsUsecase implements UseCase<List<QuestionModel>, NoParams> {
  const GetTrialQuestionsUsecase(this._repository);

  /// How many questions the free trial offers.
  static const int questionCount = 5;

  final QuizRepository _repository;

  @override
  Future<Either<Failure, List<QuestionModel>>> call(NoParams params) async {
    final result = await _repository.getAllQuestions();
    return result.map((questions) => questions.take(questionCount).toList());
  }
}