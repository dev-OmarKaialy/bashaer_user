import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Resolves a stable per-install device id and caches it in secure storage.
@lazySingleton
class DeviceIdService {
  DeviceIdService(this._storage);

  final FlutterSecureStorage _storage;
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();
  final AndroidId _androidId = const AndroidId();

  static const _storageKey = 'license_device_id';

  Future<String> getDeviceId() async {
    final cached = await _storage.read(key: _storageKey);
    if (cached != null && cached.isNotEmpty) return cached;

    final id = await _readPlatformId();
    await _storage.write(key: _storageKey, value: id);
    return id;
  }

  Future<String> _readPlatformId() async {
    if (kIsWeb) {
      return 'web-${DateTime.now().millisecondsSinceEpoch}';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final androidId = await _androidId.getId();
        if (androidId != null && androidId.trim().isNotEmpty) {
          return androidId.trim();
        }
        break;
      case TargetPlatform.iOS:
        final info = await _plugin.iosInfo;
        final id = info.identifierForVendor?.trim();
        if (id != null && id.isNotEmpty) return id;
        break;
      default:
        break;
    }
    return 'unknown-${defaultTargetPlatform.name}';
  }
}
