import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../models/license_session.dart';

/// Persists the last successful license session on device.
@lazySingleton
class LicenseSessionStore {
  LicenseSessionStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'license_session_v2';

  Future<LicenseSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = (jsonDecode(raw) as Map).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
      final session = LicenseSession.fromStorageMap(map);
      if (session.deviceId.isEmpty) return null;
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(LicenseSession session) async {
    await _storage.write(key: _key, value: jsonEncode(session.toStorageMap()));
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
