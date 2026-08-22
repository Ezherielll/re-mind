import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/db/app_database.dart';
import '../../../features/loops/data/shade_actions.dart';
import 'reminder_scheduler.dart';

/// Background entrypoint for shade actions (Done / Followed up / Snooze 1d).
@pragma('vm:entry-point')
Future<void> notificationActionHandler(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  if (actionId == null || payload == null) return;
  final loopId = int.tryParse(payload);
  if (loopId == null || shadeDbPath == null) return;
  final db = AppDatabase(NativeDatabase(File(shadeDbPath!)));
  await handleShadeAction(actionId: actionId, loopId: loopId, db: db);
  await db.close();
}

/// Set once in main so the background isolate can open the same database.
String? shadeDbPath;

const _shadeActions = [
  AndroidNotificationAction(shadeActionDone, 'Done'),
  AndroidNotificationAction(shadeActionFollowedUp, 'Followed up'),
  AndroidNotificationAction(shadeActionSnooze1d, 'Snooze 1d'),
];

/// Production [ReminderScheduler] over flutter_local_notifications.
///
/// Inexact `zonedSchedule` only — the app never requests exact-alarm
/// permissions (ADR-0003).
class RealReminderScheduler implements ReminderScheduler {
  RealReminderScheduler._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<RealReminderScheduler> create() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveBackgroundNotificationResponse: notificationActionHandler,
    );
    return RealReminderScheduler._(plugin);
  }

  tz.TZDateTime _tz(DateTime at) => tz.TZDateTime.from(at, tz.local);

  @override
  Future<void> scheduleItemAlert({
    required int loopId,
    int? notificationPayloadId,
    required String title,
    required DateTime at,
  }) async {
    await _plugin.zonedSchedule(
      id: loopId,
      title: 'Re:Mind',
      body: title,
      payload: '${notificationPayloadId ?? loopId}',
      scheduledDate: _tz(at),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'item-alerts',
          'Follow-up reminders',
          channelDescription: 'Nudges for open loops',
          actions: _shadeActions,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  @override
  Future<void> cancelItemAlert(int loopId) => _plugin.cancel(id: loopId);

  @override
  Future<void> scheduleDailyDigest({
    required int hour,
    required int minute,
    String? body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: digestId,
      title: 'Re:Mind',
      body: body ?? '',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'digest',
          'Daily check-in',
          channelDescription: 'Daily summary of hanging loops',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static const digestId = 1;

  @override
  Future<void> requestPermission() =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();
}
