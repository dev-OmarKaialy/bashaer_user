import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/training_session_model.dart';
import '../../domain/repositories/quiz_repository.dart';

class FinishSessionParams extends Equatable {
  const FinishSessionParams({required this.session});

  /// The ended session, already marked completed or stopped.
  final TrainingSessionModel session;

  @override
  List<Object> get props => [session];
}

/// Archives an ended training session and frees the active slot. A session
/// that ended before any answer is dropped instead of cluttering the history.
@injectable
class FinishSessionUsecase implements UseCase<void, FinishSessionParams> {
  FinishSessionUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(FinishSessionParams params) async {
    if (params.session.totalAttempts > 0) {
      final archived = await _repository.appendSessionHistory(params.session);
      if (archived.isLeft()) return archived;
    }
    return _repository.clearActiveSession();
  }
}
