
import '../../../core/db/app_database.dart';
import '../domain/follow_up_schedule.dart';
import 'loops_repository.dart';

/// Shade action ids used by item-alert notifications.
const shadeActionDone = 'act-done';
const shadeActionFollowedUp = 'act-followed';
const shadeActionSnooze1d = 'act-snooze-1d';

/// Applies a notification-shade action to a loop without the app open.
/// Runs inside a background isolate — owns its database handle.
Future<void> handleShadeAction({
  required String actionId,
  required int loopId,
  required AppDatabase db,
  DateTime? now,
}) async {
  final effectiveNow = now ?? DateTime.now();
  final repo = DriftLoopsRepository(db);
  switch (actionId) {
    case shadeActionDone:
      await repo.markDone(loopId);
    case shadeActionFollowedUp:
      final loop = await _anyLoop(db, loopId);
      if (loop == null) return;
      final next = nextFollowUpAfter(
        now: effectiveNow,
        currentFollowUpAt: loop.followUpAt,
        dueDate: loop.dueDate,
      );
      await repo.markFollowedUp(loopId, nextNudgeAt: next);
    case shadeActionSnooze1d:
      await repo.snoozeLoop(
        loopId,
        until: snoozeUntil(now: effectiveNow, days: 1),
      );
  }
}

/// Detail fetch that also sees done loops (getLoop is open-only until T11).
Future<Commitment?> _anyLoop(AppDatabase db, int id) {
  return (db.select(db.commitments)..where((c) => c.id.equals(id)))
      .getSingleOrNull();
}