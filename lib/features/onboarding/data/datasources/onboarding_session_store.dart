import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../models/onboarding_session.dart';

/// Persists the onboarding / free-trial funnel state on the device.
///
/// Lives next to the license session so everything that decides "what does this
/// device see first" is stored in one place.
@lazySingleton
class OnboardingSessionStore {
  OnboardingSessionStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'onboarding_session_v1';

  /// Never throws: a missing or corrupt row reads as a fresh device.
  Future<OnboardingSession> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return OnboardingSession.empty;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return OnboardingSession.empty;
      return OnboardingSession.fromStorageMap(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return OnboardingSession.empty;
    }
  }

  Future<void> write(OnboardingSession session) {
    return _storage.write(key: _key, value: jsonEncode(session.toStorageMap()));
  }

  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}
