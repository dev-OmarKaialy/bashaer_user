import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Reusable wrapper around [FirebaseMessaging].
///
/// Handles Firebase initialization, FCM token retrieval/persistence,
/// and exposes foreground / onMessageOpenedApp streams.
///
/// This class is **project-agnostic** – it has no knowledge of
/// notification channels, UI routing, or business logic.
class FirebaseMessagingService {
  FirebaseMessagingService({FirebaseMessaging? messaging, FlutterSecureStorage? secureStorage})
    : _messaging = messaging ?? FirebaseMessaging.instance,
      _storage =
          secureStorage ??
          const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FirebaseMessaging _messaging;
  final FlutterSecureStorage _storage;

  static const String _fcmTokenKey = 'fcmToken';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize Firebase (idempotent) and retrieve the FCM token.
  ///
  /// The token is persisted in secure storage and returned. Returns `null`
  /// if the token cannot be obtained.
  Future<String?> initialize(FirebaseOptions options) async {
    try {
      await Firebase.initializeApp(options: options);
      final token = await _messaging.getToken();
      if (token != null) {
        log('[FirebaseMessagingService] FCM token: $token');
        await _storage.write(key: _fcmTokenKey, value: token);
      }
      return token;
    } catch (e, st) {
      log('[FirebaseMessagingService] init failed: $e', stackTrace: st);
      return null;
    }
  }

  /// Read the cached FCM token from secure storage.
  Future<String?> getCachedToken() => _storage.read(key: _fcmTokenKey);

  // ---------------------------------------------------------------------------
  // Message streams
  // ---------------------------------------------------------------------------

  /// Listen to messages while the app is in the **foreground**.
  void onForegroundMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// Listen to messages when the user **taps** a notification that opened
  /// the app from background (not terminated).
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Register the **background** message handler.
  ///
  /// Must be a **top-level** or **static** function annotated with
  /// `@pragma('vm:entry-point')`.
  void setBackgroundHandler(Future<void> Function(RemoteMessage) handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  // ---------------------------------------------------------------------------
  // Preferences helpers (for notification toggle settings)
  // ---------------------------------------------------------------------------

  /// Read a notification preference flag from secure storage.
  Future<bool> isChannelEnabled(String key) async {
    final value = await _storage.read(key: key);
    return value != 'false'; // default = enabled
  }
}
