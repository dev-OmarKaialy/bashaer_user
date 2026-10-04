import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/question_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetAllQuestionsUsecase implements UseCase<List<QuestionModel>, NoParams> {
  GetAllQuestionsUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, List<QuestionModel>>> call(NoParams params) {
    return _repository.getAllQuestions();
  }
}
