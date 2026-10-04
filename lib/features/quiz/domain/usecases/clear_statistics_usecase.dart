import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/quiz_repository.dart';

/// Wipes the answer log and exam results, keeping bookmarks.
@injectable
class ClearStatisticsUsecase implements UseCase<void, NoParams> {
  ClearStatisticsUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.clearStatistics();
  }
}
