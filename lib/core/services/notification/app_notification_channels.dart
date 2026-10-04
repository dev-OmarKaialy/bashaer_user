import 'dart:typed_data';

import '../../../core/theme/app_theme.dart';
import 'notification_channel_config.dart';

/// All notification channel & group definitions for this app.
///
/// Centralizes channel keys, names, sounds, descriptions, and groups in one
/// place so they are easy to audit and modify.
abstract final class AppNotificationChannels {
  // ---- Channel keys --------------------------------------------------------
  static const String basic = 'basic_channel';
  static const String attendance = 'attendance';
  static const String tasks = 'tasks';
  static const String permits = 'permits';
  static const String chat = 'chat';
  static const String poke = 'poke';

  /// Ordered list of all channel keys.
  static const List<String> allKeys = [basic, attendance, tasks, permits, chat, poke];

  // ---- Group keys ----------------------------------------------------------
  static const String generalGroup = 'general_group';
  static const String workGroup = 'work_group';
  static const String messagingGroup = 'messaging_group';

  // ---- Channel Groups ------------------------------------------------------
  static const List<NotificationChannelGroupConfig> groups = [
    NotificationChannelGroupConfig(key: generalGroup, name: 'General'),
    NotificationChannelGroupConfig(key: workGroup, name: 'Work'),
    NotificationChannelGroupConfig(key: messagingGroup, name: 'Messaging'),
  ];

  // ---- Full configs --------------------------------------------------------

  static List<NotificationChannelConfig> get all => [
    const NotificationChannelConfig(
      key: basic,
      name: 'General Notifications',
      description: 'Basic instant notifications for general use.',
      channelGroupKey: generalGroup,
      defaultColor: AppTheme.primaryColor,
    ),
    const NotificationChannelConfig(
      key: attendance,
      name: 'Attendance',
      description: 'Attendance-related notifications.',
      channelGroupKey: workGroup,
      soundSource: 'resource://raw/pop',
      defaultColor: AppTheme.primaryColor,
    ),
    const NotificationChannelConfig(
      key: tasks,
      name: 'Task Notifications',
      description: 'Reminders and updates for assigned tasks.',
      channelGroupKey: workGroup,
      soundSource: 'resource://raw/popin',
      defaultColor: AppTheme.primaryColor,
    ),
    const NotificationChannelConfig(
      key: permits,
      name: 'Permit Updates',
      description: 'Alerts related to permit requests and renewals.',
      channelGroupKey: workGroup,
      soundSource: 'resource://raw/pop',
      defaultColor: AppTheme.primaryColor,
    ),
    const NotificationChannelConfig(
      key: chat,
      name: 'Chats',
      description: 'Chat message notifications.',
      channelGroupKey: messagingGroup,
      soundSource: 'resource://raw/pop',
      defaultColor: AppTheme.primaryColor,
    ),
    NotificationChannelConfig(
      key: poke,
      name: 'Pokes',
      description: 'Poke alert notifications.',
      channelGroupKey: messagingGroup,
      soundSource: 'resource://raw/alert',
      defaultColor: AppTheme.primaryColor,
      enableLights: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 2000]),
    ),
  ];
}
