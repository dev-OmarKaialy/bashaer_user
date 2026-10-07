import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class CompleteOnboardingUsecase implements UseCase<void, NoParams> {
  const CompleteOnboardingUsecase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.markOnboardingSeen();
  }
}
