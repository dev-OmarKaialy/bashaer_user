import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/subscription_plan.dart';
import '../repositories/subscription_repository.dart';

/// The one plan the subscribe screen offers: a monthly subscription.
@lazySingleton
class GetMonthlyPlanUsecase implements UseCase<SubscriptionPlan?, NoParams> {
  const GetMonthlyPlanUsecase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionPlan?>> call(NoParams params) {
    return _repository.getPlan(SubscriptionPlan.monthlyId);
  }
}
