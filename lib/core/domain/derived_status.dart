/// Display-only urgency vocabulary (CONTEXT.md "Derived status").
///
/// Computed at render time from the stored dates — never persisted. The
/// single implementation lives here; UI and sorting both consume it.
enum DerivedStatus {
  followUpDue,
  due,
  upcoming,
  onTrack;

  /// Sort precedence, lowest value = most urgent.
  int get precedence => index;
}

/// Derives the urgency label for one open loop. Done loops never reach this
/// function (the open-loops query filters them upstream).
DerivedStatus deriveStatus({
  required DateTime now,
  DateTime? followUpAt,
  DateTime? dueDate,
}) {
  // 1. Follow-up due — the nudge time has been reached.
  if (followUpAt != null && !followUpAt.isAfter(now)) {
    return DerivedStatus.followUpDue;
  }

  if (dueDate != null) {
    // 2. Due — the due date is today or earlier (date components only).
    final todayStart = DateTime(now.year, now.month, now.day);
    final dueStart = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (!dueStart.isAfter(todayStart)) {
      return DerivedStatus.due;
    }
    // 3. Upcoming — a future due date.
    return DerivedStatus.upcoming;
  }

  // 4. On track — nothing triggered.
  return DerivedStatus.onTrack;
}
