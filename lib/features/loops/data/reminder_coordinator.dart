import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/digest.dart';
import '../../../core/notifications/reminder_scheduler.dart';
import 'loops_repository.dart';

/// Notification id offset for same-day due-date alerts (item nudges use the
/// raw loop id).
const int dueTodayIdOffset = 100000;

/// Keeps scheduled item alerts in sync with the open-loop list: schedules
/// new/changed follow-ups, cancels ones that disappeared (done/deleted/
/// re-planned). Diffing state lives here so the scheduler stays stateless.
class ReminderCoordinator {
  ReminderCoordinator(this._scheduler);

  final ReminderScheduler _scheduler;
  final _scheduled = <int, DateTime>{};
  final _scheduledDueToday = <int, DateTime>{};

  Map<int, DateTime> get scheduledForTest => Map.unmodifiable(_scheduled);

  Future<void> sync(
    List<LoopWithPerson> openLoops, {
    String Function(String title)? dueTodayTitle,
    DateTime? now,
    String? digestBody,
    (int, int)? digestTime,
  }) async {
    final effectiveNow = now ?? DateTime.now();
    final desired = <int, DateTime>{};
    final dueToday = <int, DateTime>{};
    for (final l in openLoops) {
      final at = l.commitment.followUpAt;
      if (at != null && at.isAfter(effectiveNow)) {
        desired[l.commitment.id] = at;
      }
      final due = l.commitment.dueDate;
      if (isDueToday(due, effectiveNow)) {
        // Fire at 09:00 on the due day; if that moment already passed we
        // skip entirely (no cancel/reschedule churn on every emission).
        final d = due!;
        final fireAt = DateTime(d.year, d.month, d.day, 9);
        if (fireAt.isAfter(effectiveNow)) {
          dueToday[l.commitment.id] = fireAt;
        }
      }
    }

    Future<void> reconcile(
      Map<int, DateTime> current,
      Map<int, DateTime> target, {
      required Future<void> Function(int id) cancel,
      required Future<void> Function(int id, DateTime at, String title) schedule,
    }) async {
      for (final id in current.keys.toSet()) {
        if (target[id] != current[id]) {
          await cancel(id);
          current.remove(id);
        }
      }
      for (final entry in target.entries) {
        if (current[entry.key] != entry.value) {
          final loop =
              openLoops.where((l) => l.commitment.id == entry.key).first;
          await schedule(entry.key, entry.value, loop.commitment.title);
          current[entry.key] = entry.value;
        }
      }
    }

    await reconcile(
      _scheduled,
      desired,
      cancel: _scheduler.cancelItemAlert,
      schedule: (id, at, title) => _scheduler.scheduleItemAlert(
        loopId: id,
        title: title,
        at: at,
      ),
    );
    await reconcile(
      _scheduledDueToday,
      dueToday,
      cancel: (id) => _scheduler.cancelItemAlert(id + dueTodayIdOffset),
      schedule: (id, at, title) => _scheduler.scheduleItemAlert(
        loopId: id + dueTodayIdOffset,
          notificationPayloadId: id,
          title: dueTodayTitle == null ? title : dueTodayTitle(title),
        at: at,
      ),
    );

    if (digestTime != null) {
      await _scheduler.scheduleDailyDigest(
        hour: digestTime.$1,
        minute: digestTime.$2,
        body: digestBody,
      );
    }
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('override with RealReminderScheduler in main'),
);

final reminderCoordinatorProvider = Provider<ReminderCoordinator>(
  (ref) => ReminderCoordinator(ref.watch(reminderSchedulerProvider)),
);