import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local-only notification service for IKO.
///
/// - Schedules per-quest reminders (one-shot at a chosen `DateTime`).
/// - Schedules a daily reflection nudge at a user-chosen hour.
/// - Cancels reminders when quests are completed / deleted.
///
/// No push servers, no third parties. Everything happens on-device.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Stable ID space — quest reminders use the quest id directly.
  /// Reserved IDs (avoid collisions with future quest ids).
  static const int dailyReflectionId = 1000001;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tz_data.initializeTimeZones();
    // Best-effort local timezone. Falls back to UTC if unknown.
    try {
      tz.setLocalLocation(tz.getLocation(tz.local.name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Asks the user for OS-level notification permission.
  /// Safe to call multiple times.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await init();

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return false;
  }

  NotificationDetails get _questDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'iko_quests',
          'Quest reminders',
          channelDescription: 'Reminders for IKO quests you have committed to.',
          importance: Importance.high,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      );

  NotificationDetails get _dailyDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          'iko_daily',
          'Daily reflection',
          channelDescription: 'A single daily nudge to log activity and reflect.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Schedules a one-shot reminder for [questId] at [when].
  /// If [when] is in the past, this is a no-op.
  Future<void> scheduleQuestReminder({
    required int questId,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (kIsWeb) return;
    await init();

    final target = tz.TZDateTime.from(when, tz.local);
    if (target.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      questId,
      title,
      body,
      target,
      _questDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  /// Schedules (or replaces) the recurring daily nudge.
  Future<void> scheduleDailyReflection({int hour = 20, int minute = 0}) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(dailyReflectionId);

    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) first = first.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      dailyReflectionId,
      'A moment to reflect',
      'Log today\'s quests and close the loop.',
      first,
      _dailyDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelForQuest(int questId) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(questId);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancelAll();
  }
}
