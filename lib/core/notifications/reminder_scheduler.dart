/// Platform seam for local notifications (ADR-0003: inexact one-shots and a
/// daily digest; no exact alarms). Logic/tests depend on this interface;
/// [RealReminderScheduler] isolates flutter_local_notifications.
abstract class ReminderScheduler {
  /// One-shot alert for an open loop's followUpAt. [notificationPayloadId]
  /// lets callers decouple the Android notification id from the loop id
  /// carried in the payload (due-today alerts offset the id).
  Future<void> scheduleItemAlert({
    required int loopId,
    int? notificationPayloadId,
    required String title,
    required DateTime at,
  });

  Future<void> cancelItemAlert(int loopId);

  /// Repeating daily check-in at the user's chosen time. [body] is composed
  /// from live data at schedule time and refreshed on every sync.
  Future<void> scheduleDailyDigest({
    required int hour,
    required int minute,
    String? body,
  });

  /// Runtime notification permission (Android 13+). Called contextually by
  /// the onboarding flow (T09), never at first launch.
  Future<void> requestPermission();
}
