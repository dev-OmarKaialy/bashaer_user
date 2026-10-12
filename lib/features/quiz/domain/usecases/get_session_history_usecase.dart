import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/training_session_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetSessionHistoryUsecase implements UseCase<List<TrainingSessionModel>, NoParams> {
  GetSessionHistoryUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, List<TrainingSessionModel>>> call(NoParams params) {
    return _repository.getSessionHistory();
  }
}
