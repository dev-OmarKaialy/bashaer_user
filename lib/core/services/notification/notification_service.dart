import 'dart:math' hide log;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'notification_channel_config.dart';

/// A callback signature for when a notification action is received (tapped).
typedef NotificationActionHandler = Future<void> Function(ReceivedAction action);

/// Core notification service wrapping [AwesomeNotifications].
///
/// This class is **project-agnostic** – it knows nothing about Firebase,
/// routing, or business logic. It only deals with local notification
/// initialization, creation, permission, and event wiring.
///
/// Usage:
/// ```dart
/// final service = NotificationService();
/// await service.initialize(
///   icon: 'resource://drawable/ic_notification',
///   channels: myChannelConfigs,
/// );
/// ```
class NotificationService {
  NotificationService({AwesomeNotifications? awesomeNotifications})
    : _notifications = awesomeNotifications ?? AwesomeNotifications();

  final AwesomeNotifications _notifications;

  /// Exposes the underlying instance for edge-case direct access.
  AwesomeNotifications get instance => _notifications;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize local notification channels and optional channel groups.
  Future<void> initialize({
    required String icon,
    required List<NotificationChannelConfig> channels,
    List<NotificationChannelGroupConfig>? channelGroups,
    bool debug = false,
  }) async {
    await _notifications.initialize(
      icon,
      channels.map((c) => c.toChannel()).toList(),
      channelGroups: channelGroups?.map((g) => g.toGroup()).toList(),
      debug: debug,
    );
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  /// Returns `true` when the app is allowed to post notifications.
  Future<bool> isAllowed() => _notifications.isNotificationAllowed();

  /// Requests the OS permission dialog. Returns `true` if granted.
  Future<bool> requestPermission() => _notifications.requestPermissionToSendNotifications();

  /// Convenience: checks permission and, if missing, requests it.
  /// Calls [onReady] once permission is confirmed.
  Future<void> ensurePermission({VoidCallback? onReady}) async {
    final allowed = await isAllowed();
    if (!allowed) {
      final granted = await requestPermission();
      if (granted) onReady?.call();
    } else {
      onReady?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // Listeners
  // ---------------------------------------------------------------------------

  /// Wire up notification lifecycle callbacks.
  Future<void> setListeners({
    required NotificationActionHandler onActionReceived,
    Future<void> Function(ReceivedNotification)? onCreated,
    Future<void> Function(ReceivedNotification)? onDisplayed,
    Future<void> Function(ReceivedAction)? onDismissed,
  }) async {
    _notifications.setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onCreated ?? _noOp,
      onNotificationDisplayedMethod: onDisplayed ?? _noOp,
      onDismissActionReceivedMethod: onDismissed ?? _noOpAction,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> _noOp(ReceivedNotification _) async {}

  @pragma("vm:entry-point")
  static Future<void> _noOpAction(ReceivedAction _) async {}

  // ---------------------------------------------------------------------------
  // Create notifications
  // ---------------------------------------------------------------------------

  /// Show a local notification.
  ///
  /// Each notification gets a unique random [id] by default. Pass a specific
  /// [id] only when you want to **update** an existing notification.
  ///
  /// [groupKey] controls Android notification grouping. Notifications with the
  /// same [groupKey] are visually stacked in the system tray. If omitted, no
  /// grouping is applied (each notification stands alone).
  ///
  /// [autoDismissible] — when `false`, tapping or swiping one notification
  /// will **not** dismiss sibling notifications in the same group. Defaults
  /// to `true` (standard Android behavior).
  Future<void> show({
    required String channelKey,
    required String? title,
    required String? body,
    Map<String, String?>? payload,
    String? groupKey,
    int? id,
    bool autoDismissible = true,
  }) async {
    await _notifications.createNotification(
      content: NotificationContent(
        id: id ?? Random().nextInt(10000000),
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        criticalAlert: true,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: true,
        autoDismissible: autoDismissible,
        // Only set groupKey when explicitly provided.
        // This prevents Android from auto-grouping unrelated notifications
        // and dismissing siblings when one is interacted with.
        groupKey: groupKey,
      ),
    );
  }
}
