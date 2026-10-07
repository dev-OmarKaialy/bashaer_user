import 'package:dartz/dartz.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../data/models/subscription_plan.dart';

abstract class SubscriptionRepository {
  /// The plan the subscribe screen shows.
  ///
  /// Right(null) means the school has not published that plan; a Left means the
  /// read failed and nothing was cached.
  Future<Either<Failure, SubscriptionPlan?>> getPlan(String planId);
}
