import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/quiz_repository.dart';

/// Wipes the saved (bookmarked) questions, keeping statistics.
@injectable
class ClearBookmarksUsecase implements UseCase<void, NoParams> {
  ClearBookmarksUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.clearBookmarks();
  }
}
