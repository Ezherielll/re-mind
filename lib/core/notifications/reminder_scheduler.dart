/// Platform seam for local notifications (ADR-0003: inexact one-shots and a
/// daily digest; no exact alarms). Logic/tests depend on this interface;
/// [RealReminderScheduler] isolates flutter_local_notifications.
abstract class ReminderScheduler {
  /// One-shot alert for an open loop's followUpAt.
  Future<void> scheduleItemAlert({
    required int loopId,
    required String title,
    required DateTime at,
  });

  Future<void> cancelItemAlert(int loopId);

  /// Repeating daily check-in at the user's chosen time.
  Future<void> scheduleDailyDigest({required int hour, required int minute});

  /// Runtime notification permission (Android 13+). Called contextually by
  /// the onboarding flow (T09), never at first launch.
  Future<void> requestPermission();
}
