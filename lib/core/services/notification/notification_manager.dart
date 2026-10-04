//TODO! if app has firebase use this file to enable it

// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// import '../../../firebase_options.dart';
// import 'app_notification_channels.dart';
// import 'app_notification_handler.dart';
// import 'firebase_messaging_service.dart';
// import 'notification_service.dart';

// /// High-level façade that wires together [NotificationService],
// /// [FirebaseMessagingService], and [AppNotificationHandler].
// ///
// /// This replaces the old `NotificationUtils` class. Call sites should use
// /// `NotificationManager()` which returns the singleton instance.
// ///
// /// **Backward-compatible API:**
// /// - `configuration()` → initializes everything, returns the FCM token.
// /// - `checkingPermissionNotification()` → requests permission + wires listeners.
// /// - `listenToNotification()` → static, for background handler usage.
// class NotificationManager {
//   NotificationManager._();

//   factory NotificationManager() => _instance;
//   static final NotificationManager _instance = NotificationManager._();

//   final NotificationService notificationService = NotificationService();
//   final FirebaseMessagingService messagingService = FirebaseMessagingService();

//   // ---------------------------------------------------------------------------
//   // Configuration
//   // ---------------------------------------------------------------------------

//   /// Initialize Firebase + local notification channels, start listening
//   /// for foreground / opened-app messages, and return the FCM token.
//   Future<String?> configuration() async {
//     try {
//       // 1. Firebase + FCM token
//       final fcmToken = await messagingService.initialize(DefaultFirebaseOptions.currentPlatform);

//       // 2. Awesome Notifications channels + groups
//       await notificationService.initialize(
//         icon: 'resource://drawable/ic_notification',
//         channels: AppNotificationChannels.all,
//         channelGroups: AppNotificationChannels.groups,
//       );

//       // 3. Start listening to foreground & opened-app messages
//       _startListening();

//       return fcmToken;
//     } catch (e, st) {
//       log('[NotificationManager] configuration failed: $e', stackTrace: st);
//       return null;
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // Permission
//   // ---------------------------------------------------------------------------

//   /// Check (and optionally request) notification permission, then wire up
//   /// notification event listeners.
//   Future<void> checkingPermissionNotification(BuildContext context) async {
//     await notificationService.ensurePermission(onReady: () => _startNotificationEventListeners());
//   }

//   // ---------------------------------------------------------------------------
//   // Static entry point for background handler
//   // ---------------------------------------------------------------------------

//   /// Process a [RemoteMessage] into a local notification.
//   ///
//   /// Can be called from a background isolate (e.g. `main.dart`).
//   @pragma('vm:entry-point')
//   static Future<void> listenToNotification(RemoteMessage message, {bool withChat = false}) async {
//     await AppNotificationHandler.handleMessage(
//       message,
//       notificationService: NotificationManager().notificationService,
//       messagingService: NotificationManager().messagingService,
//       withChat: withChat,
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // Internals
//   // ---------------------------------------------------------------------------

//   void _startListening() {
//     messagingService.onForegroundMessage((m) async {
//       if (await notificationService.isAllowed()) {
//         await listenToNotification(m);
//       }
//     });

//     messagingService.onMessageOpenedApp((m) async {
//       if (await notificationService.isAllowed()) {
//         await listenToNotification(m);
//       }
//     });
//   }

//   Future<void> _startNotificationEventListeners() async {
//     log('[NotificationManager] wiring notification event listeners');
//     await notificationService.setListeners(
//       onActionReceived: AppNotificationHandler.onNotificationTapped,
//     );
//   }
// }
