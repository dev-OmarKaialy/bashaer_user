import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the installed app's version so widgets don't call the plugin directly.
@lazySingleton
class AppInfoService {
  AppInfo? _cached;

  /// Version and build number of the running app, read once per process.
  Future<AppInfo> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final info = await PackageInfo.fromPlatform();
    return _cached = AppInfo(version: info.version, buildNumber: info.buildNumber);
  }
}

class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  /// e.g. `1.2.0 (14)`; the build number is dropped when the platform has none.
  String get display => buildNumber.isEmpty ? version : '$version ($buildNumber)';
}
