import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../models/subscription_plan.dart';

/// Caches the last plan the school published, so the subscribe screen still
/// shows the right price when the device is offline.
@lazySingleton
class SubscriptionPlanStore {
  SubscriptionPlanStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'subscription_plan_v1';

  /// Never throws: a missing or corrupt row simply means "no cached price".
  Future<SubscriptionPlan?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return SubscriptionPlan.fromStorageMap(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(SubscriptionPlan plan) {
    return _storage.write(key: _key, value: jsonEncode(plan.toStorageMap()));
  }

  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}
