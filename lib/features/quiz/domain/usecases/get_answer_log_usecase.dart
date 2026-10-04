import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/quiz_result_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetAnswerLogUsecase implements UseCase<List<AnswerLogEntry>, NoParams> {
  GetAnswerLogUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, List<AnswerLogEntry>>> call(NoParams params) {
    return _repository.getAnswerLog();
  }
}
