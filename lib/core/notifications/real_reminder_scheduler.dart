import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'reminder_scheduler.dart';

/// Production [ReminderScheduler] over flutter_local_notifications.
///
/// Inexact `zonedSchedule` only — the app never requests exact-alarm
/// permissions (ADR-0003). The plugin's ScheduledNotificationBootReceiver
/// (registered in AndroidManifest) re-fires pending one-shots after reboot.
class RealReminderScheduler implements ReminderScheduler {
  RealReminderScheduler._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<RealReminderScheduler> create() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await FlutterLocalNotificationsPlugin().initialize(
      settings: const InitializationSettings(android: android),
    );
    return RealReminderScheduler._(FlutterLocalNotificationsPlugin());
  }

  tz.TZDateTime _tz(DateTime at) => tz.TZDateTime.from(at, tz.local);

  @override
  Future<void> scheduleItemAlert({
    required int loopId,
    required String title,
    required DateTime at,
  }) async {
    await _plugin.zonedSchedule(
      id: loopId,
      title: 'Re:Mind',
      body: title,
      scheduledDate: _tz(at),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'item-alerts',
          'Follow-up reminders',
          channelDescription: 'Nudges for open loops',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  @override
  Future<void> cancelItemAlert(int loopId) => _plugin.cancel(id: loopId);

  @override
  Future<void> scheduleDailyDigest({required int hour, required int minute}) async {
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
      body: '', // Body is composed at fire time in T08 via background handler.
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
