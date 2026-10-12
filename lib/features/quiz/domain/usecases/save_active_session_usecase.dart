import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/training_session_model.dart';
import '../../domain/repositories/quiz_repository.dart';

class SaveActiveSessionParams extends Equatable {
  const SaveActiveSessionParams({required this.session});

  final TrainingSessionModel session;

  @override
  List<Object> get props => [session];
}

@injectable
class SaveActiveSessionUsecase implements UseCase<void, SaveActiveSessionParams> {
  SaveActiveSessionUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(SaveActiveSessionParams params) {
    return _repository.saveActiveSession(params.session);
  }
}
