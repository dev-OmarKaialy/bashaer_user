import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Channel Group
// ---------------------------------------------------------------------------

/// Reusable config for a notification channel group.
///
/// On Android 8+, channel groups let users bulk-manage related channels
/// in system settings.
class NotificationChannelGroupConfig {
  final String key;
  final String name;

  const NotificationChannelGroupConfig({required this.key, required this.name});

  NotificationChannelGroup toGroup() {
    return NotificationChannelGroup(channelGroupKey: key, channelGroupName: name);
  }
}

// ---------------------------------------------------------------------------
// Channel
// ---------------------------------------------------------------------------

/// Reusable configuration model for a notification channel.
///
/// Encapsulates all parameters needed to register a channel with
/// [AwesomeNotifications]. Create a list of these and pass them to
/// [NotificationService.initialize].
class NotificationChannelConfig {
  final String key;
  final String name;
  final String description;
  final String? channelGroupKey;
  final String? soundSource;
  final Color defaultColor;
  final NotificationImportance importance;
  final bool showBadge;
  final bool enableVibration;
  final Int64List? vibrationPattern;
  final bool playSound;
  final bool onlyAlertOnce;
  final bool criticalAlerts;
  final NotificationPrivacy privacy;
  final bool enableLights;
  final DefaultRingtoneType ringtoneType;
  final GroupAlertBehavior groupAlertBehavior;
  final GroupSort groupSort;

  const NotificationChannelConfig({
    required this.key,
    required this.name,
    this.description = '',
    this.channelGroupKey,
    this.soundSource,
    this.defaultColor = Colors.blue,
    this.importance = NotificationImportance.Max,
    this.showBadge = true,
    this.enableVibration = true,
    this.vibrationPattern,
    this.playSound = true,
    this.onlyAlertOnce = false,
    this.criticalAlerts = true,
    this.privacy = NotificationPrivacy.Public,
    this.enableLights = false,
    this.ringtoneType = DefaultRingtoneType.Notification,
    this.groupAlertBehavior = GroupAlertBehavior.Children,
    this.groupSort = GroupSort.Desc,
  });

  /// Converts this config into an [AwesomeNotifications] channel.
  NotificationChannel toChannel() {
    return NotificationChannel(
      channelKey: key,
      channelName: name,
      channelDescription: description,
      channelGroupKey: channelGroupKey,
      soundSource: soundSource,
      defaultColor: defaultColor,
      importance: importance,
      channelShowBadge: showBadge,
      enableVibration: enableVibration,
      vibrationPattern: vibrationPattern,
      playSound: playSound,
      onlyAlertOnce: onlyAlertOnce,
      criticalAlerts: criticalAlerts,
      defaultPrivacy: privacy,
      enableLights: enableLights,
      defaultRingtoneType: ringtoneType,
      groupAlertBehavior: groupAlertBehavior,
      groupSort: groupSort,
    );
  }
}
