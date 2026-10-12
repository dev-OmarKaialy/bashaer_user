import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/training_session_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetActiveSessionUsecase implements UseCase<TrainingSessionModel?, NoParams> {
  GetActiveSessionUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, TrainingSessionModel?>> call(NoParams params) {
    return _repository.getActiveSession();
  }
}
