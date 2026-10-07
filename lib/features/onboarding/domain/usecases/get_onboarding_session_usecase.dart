import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/onboarding_session.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class GetOnboardingSessionUsecase implements UseCase<OnboardingSession, NoParams> {
  const GetOnboardingSessionUsecase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<Either<Failure, OnboardingSession>> call(NoParams params) {
    return _repository.readSession();
  }
}
