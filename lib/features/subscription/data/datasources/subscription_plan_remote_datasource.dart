import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../../../core/unified_api/error/error_handeler.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../models/subscription_error_codes.dart';
import '../models/subscription_plan.dart';

/// Reads the `subscription_plans` collection, written by the admin app.
///
/// Each plan is one document keyed by its `planId` (e.g. `monthly`), so a
/// lookup is a direct `doc(planId).get()`.
abstract class SubscriptionPlanRemoteDatasource {
  /// The plan, or null when the school has not published that one yet.
  Future<SubscriptionPlan?> getPlan(String planId);
}

@Injectable(as: SubscriptionPlanRemoteDatasource)
class SubscriptionPlanRemoteDatasourceImpl implements SubscriptionPlanRemoteDatasource {
  SubscriptionPlanRemoteDatasourceImpl();

  static const _plansCollection = 'subscription_plans';

  @override
  Future<SubscriptionPlan?> getPlan(String planId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(_plansCollection).doc(planId).get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return SubscriptionPlan.fromFirestore(data, fallbackId: planId);
    } on FirebaseException catch (e) {
      log('Subscription plan fetch failed: ${e.message}'.logYellow);
      throw _failure(e);
    }
  }

  ServerFailure _failure(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return const ServerFailure(
        message: SubscriptionErrorCodes.permissionDenied,
        statusCode: ResponseCode.DEFAULT,
      );
    }
    return const ServerFailure(
      message: SubscriptionErrorCodes.offline,
      statusCode: ResponseCode.NO_INTERNET_CONNECTION,
    );
  }
}
