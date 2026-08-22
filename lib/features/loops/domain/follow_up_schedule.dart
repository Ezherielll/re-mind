import 'package:re_mind/core/domain/commitment.dart';

/// Deterministic follow-up scheduling (CONTEXT.md "Follow-up trigger").
///
/// Pure function: no clock reads, no I/O — the caller supplies `now`.
const defaultReminderHour = 9;

DateTime _atNine(DateTime day) =>
    DateTime(day.year, day.month, day.day, defaultReminderHour);

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
