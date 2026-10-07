import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class CompleteFreeTrialUsecase implements UseCase<void, NoParams> {
  const CompleteFreeTrialUsecase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.markTrialCompleted();
  }
}
