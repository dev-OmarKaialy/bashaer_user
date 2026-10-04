import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetBookmarkedIdsUsecase implements UseCase<Set<String>, NoParams> {
  GetBookmarkedIdsUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, Set<String>>> call(NoParams params) {
    return _repository.getBookmarkedQuestionIds();
  }
}
