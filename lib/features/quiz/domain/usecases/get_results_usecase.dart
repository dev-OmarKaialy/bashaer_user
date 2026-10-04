import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/quiz_result_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetResultsUsecase implements UseCase<List<QuizResultModel>, NoParams> {
  GetResultsUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, List<QuizResultModel>>> call(NoParams params) {
    return _repository.getResults();
  }
}
