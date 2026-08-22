import 'package:re_mind/core/domain/commitment.dart';

/// Deterministic follow-up scheduling (CONTEXT.md "Follow-up trigger").
///
/// Pure function: no clock reads, no I/O — the caller supplies `now`.
const defaultReminderHour = 9;

/// Snaps a picked date to the default reminder time (09:00 local).
DateTime atReminderHour(DateTime day) =>
    DateTime(day.year, day.month, day.day, defaultReminderHour);

DateTime _atNine(DateTime day) => atReminderHour(day);

DateTime _plusThreeDays(DateTime now) {
  final candidate = _atNine(now.add(const Duration(days: 3)));
  if (candidate.isAfter(now)) return candidate;
  // Edge: 09:00 three days out is not in the future (captured before 09:00
  // on that day boundary) — slide to the following day.
  return candidate.add(const Duration(days: 1));
}

/// The dates to persist for a newly captured (or re-planned) commitment.
typedef SchedulePlan = ({DateTime? dueDate, DateTime? followUpAt});

SchedulePlan computeSchedule({
  required Direction direction,
  required DateTime now,
  DateTime? dueDate,
  DateTime? followUpAt,
}) {
  // An explicit chip/custom choice always wins.
  if (followUpAt != null) {
    return (dueDate: dueDate, followUpAt: followUpAt);
  }

  if (direction == Direction.outgoing && dueDate != null) {
    final dayBefore = _atNine(dueDate.subtract(const Duration(days: 1)));
    if (dayBefore.isAfter(now)) {
      return (dueDate: dueDate, followUpAt: dayBefore);
    }
    if (dueDate.isAfter(now)) {
      return (dueDate: dueDate, followUpAt: _atNine(dueDate));
    }
    // Due already passed at capture: treat like no plan.
    return (dueDate: dueDate, followUpAt: _plusThreeDays(now));
  }

  return (dueDate: dueDate, followUpAt: _plusThreeDays(now));
}

/// The snooze-cycle rule (CONTEXT.md "Follow-up trigger"): after acting on a
/// nudge, the next one lands on the due date if it is still ahead, otherwise
/// three days out at 09:00.
DateTime nextFollowUpAfter({
  required DateTime now,
  DateTime? currentFollowUpAt,
  DateTime? dueDate,
}) {
  if (dueDate != null &&
      dueDate.isAfter(now) &&
      (currentFollowUpAt == null || currentFollowUpAt.isBefore(dueDate))) {
    return _atNine(dueDate);
  }
  return _plusThreeDays(now);
}

/// Snoozes a nudge by whole days, snapped to 09:00; if the snapped time is
/// not in the future it slides one more day.
DateTime snoozeUntil({required DateTime now, required int days}) {
  final candidate = _atNine(now.add(Duration(days: days)));
  if (candidate.isAfter(now)) return candidate;
  return candidate.add(const Duration(days: 1));
}
