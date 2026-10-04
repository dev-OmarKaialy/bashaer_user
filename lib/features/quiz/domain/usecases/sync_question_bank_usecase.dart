import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/quiz_repository.dart';

@injectable
class SyncQuestionBankUsecase implements UseCase<void, SyncQuestionBankParams> {
  SyncQuestionBankUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, void>> call(SyncQuestionBankParams params) {
    return _repository.syncQuestionBank(onProgress: params.onProgress);
  }
}

class SyncQuestionBankParams extends Equatable {
  const SyncQuestionBankParams({this.onProgress});

  /// Called with the 0–1 completion of the sync as each stage finishes.
  final void Function(double progress)? onProgress;

  @override
  List<Object?> get props => [onProgress];
}
