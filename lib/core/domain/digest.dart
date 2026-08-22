/// Digest body composition (T08).
///
/// Composed at SCHEDULE time from live counts; the digest is re-scheduled on
/// every open-loop change so the body stays fresh without a headless task
/// (ADR-0003). Templates are injected so the caller localizes.
String composeDigestBody({
  required int totalOpen,
  required int dueToday,
  required String noneTemplate,
  required String Function(Object count) hangingTemplate,
  required String Function(Object count) chaseTemplate,
}) {
  if (totalOpen == 0) return noneTemplate;
  final base = hangingTemplate(totalOpen);
  if (dueToday > 0) {
    return base + chaseTemplate(dueToday);
  }
  return base;
}

/// True when [dueDate] falls on the same local day as [now].
bool isDueToday(DateTime? dueDate, DateTime now) {
  if (dueDate == null) return false;
  return dueDate.year == now.year &&
      dueDate.month == now.month &&
      dueDate.day == now.day;
}
