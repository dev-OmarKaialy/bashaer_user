import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/quiz_result_model.dart';
import '../../domain/repositories/quiz_repository.dart';

class SaveResultParams extends Equatable {
  const SaveResultParams({required this.result});

  final QuizResultModel result;

  @override
  List<Object> get props => [result];
}

@injectable
class SaveResultUsecase implements UseCase<void, SaveResultParams> {
  SaveResultUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(SaveResultParams params) {
    return _repository.saveResult(params.result);
  }
}
