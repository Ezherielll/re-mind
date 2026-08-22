import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/reminder_scheduler.dart';
import 'loops_repository.dart';

/// Keeps scheduled item alerts in sync with the open-loop list: schedules
/// new/changed follow-ups, cancels ones that disappeared (done/deleted/
/// re-planned). Diffing state lives here so the scheduler stays stateless.
class ReminderCoordinator {
  ReminderCoordinator(this._scheduler);

  final ReminderScheduler _scheduler;
  final _scheduled = <int, DateTime>{};

  Map<int, DateTime> get scheduledForTest => Map.unmodifiable(_scheduled);

  Future<void> sync(List<LoopWithPerson> openLoops) async {
    final desired = <int, DateTime>{};
    for (final l in openLoops) {
      final at = l.commitment.followUpAt;
      if (at != null && at.isAfter(DateTime.now())) {
        desired[l.commitment.id] = at;
      }
    }

    // Cancel removed or moved.
    for (final id in _scheduled.keys.toSet()) {
      if (desired[id] != _scheduled[id]) {
        await _scheduler.cancelItemAlert(id);
        _scheduled.remove(id);
      }
    }
    // Schedule new or moved.
    for (final entry in desired.entries) {
      if (_scheduled[entry.key] != entry.value) {
        final loop = openLoops.firstWhere((l) => l.commitment.id == entry.key);
        await _scheduler.scheduleItemAlert(
          loopId: entry.key,
          title: loop.commitment.title,
          at: entry.value,
        );
        _scheduled[entry.key] = entry.value;
      }
    }
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('override with RealReminderScheduler in main'),
);

final reminderCoordinatorProvider = Provider<ReminderCoordinator>(
  (ref) => ReminderCoordinator(ref.watch(reminderSchedulerProvider)),
);
