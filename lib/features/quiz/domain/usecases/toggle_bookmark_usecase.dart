import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/quiz_repository.dart';

class ToggleBookmarkParams extends Equatable {
  const ToggleBookmarkParams({required this.questionId});

  final String questionId;

  @override
  List<Object> get props => [questionId];
}

@injectable
class ToggleBookmarkUsecase implements UseCase<Set<String>, ToggleBookmarkParams> {
  ToggleBookmarkUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, Set<String>>> call(ToggleBookmarkParams params) {
    return _repository.toggleBookmark(params.questionId);
  }
}
