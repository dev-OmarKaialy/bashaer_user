import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/quiz_repository.dart';

class RecordAnswerParams extends Equatable {
  const RecordAnswerParams({required this.questionId, required this.wasCorrect});

  final String questionId;
  final bool wasCorrect;

  @override
  List<Object> get props => [questionId, wasCorrect];
}

@injectable
class RecordAnswerUsecase implements UseCase<void, RecordAnswerParams> {
  RecordAnswerUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(RecordAnswerParams params) {
    return _repository.recordAnswer(params.questionId, params.wasCorrect);
  }
}
