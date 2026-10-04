import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_messaging_service.dart';
import 'notification_service.dart';

/// App-specific handler that bridges incoming [RemoteMessage]s to the correct
/// local notification, Bloc event, or navigation action.
///
/// This is the **only** file you need to change when porting the notification
/// layer to a different project. All reusable plumbing lives in
/// [NotificationService] and [FirebaseMessagingService].
class AppNotificationHandler {
  AppNotificationHandler({required this.notificationService, required this.messagingService});

  final NotificationService notificationService;
  final FirebaseMessagingService messagingService;

  /// Known channel keys used by this project.
  static const List<String> channelKeys = [
    'basic_channel',
    'attendance',
    'tasks',
    'permits',
    'chat',
    'poke',
  ];

  // ---------------------------------------------------------------------------
  // Incoming message processing
  // ---------------------------------------------------------------------------

  /// Process an incoming [RemoteMessage] and show a local notification
  /// or update the relevant Bloc.
  ///
  /// [withChat] – when `true`, chat messages are shown as notifications
  /// rather than being dispatched to [ChatBloc] (e.g. background handler).
  @pragma('vm:entry-point')
  static Future<void> handleMessage(
    RemoteMessage message, {
    required NotificationService notificationService,
    required FirebaseMessagingService messagingService,
    bool withChat = false,
  }) async {
    {
      await notificationService.show(
        channelKey: 'basic_channel',
        title: message.data['title'] ?? message.notification?.title,
        body: message.data['body'] ?? message.notification?.body,
        payload: message.data.cast(),
        autoDismissible: false,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Notification tap (action) handler
  // ---------------------------------------------------------------------------

  /// Called when the user taps on a notification.
  @pragma("vm:entry-point")
  static Future<void> onNotificationTapped(ReceivedAction action) async {}
}
