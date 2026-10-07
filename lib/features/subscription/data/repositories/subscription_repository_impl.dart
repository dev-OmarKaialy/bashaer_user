import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_plan_remote_datasource.dart';
import '../datasources/subscription_plan_store.dart';
import '../models/subscription_plan.dart';

@Injectable(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._remote, this._store);

  final SubscriptionPlanRemoteDatasource _remote;
  final SubscriptionPlanStore _store;

  @override
  Future<Either<Failure, SubscriptionPlan?>> getPlan(String planId) async {
    try {
      final plan = await _remote.getPlan(planId);
      if (plan != null) await _store.write(plan);
      return Right(plan);
    } on Failure catch (e) {
      // The cached price is better than none while the device is offline; only
      // fail when there is nothing to fall back to.
      final cached = await _store.read();
      return cached == null ? Left(e) : Right(cached);
    }
  }
}
