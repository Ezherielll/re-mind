import 'package:flutter/material.dart';

import '../../../core/domain/commitment.dart';
import '../../../core/domain/derived_status.dart';
import '../data/loops_repository.dart';

/// One non-empty urgency section of the home list.
class LoopGroup {
  const LoopGroup({required this.status, required this.loops});

  final DerivedStatus status;
  final List<LoopWithPerson> loops;
}

/// Groups open loops by derived status in fixed precedence order
/// (pages/home.md). Empty groups are omitted; [directionFilter] narrows to
/// one Direction when set. Pure: inject [now].
List<LoopGroup> groupOpenLoops(
  Iterable<LoopWithPerson> loops, {
  Direction? directionFilter,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final filtered = directionFilter == null
      ? loops.where((l) => true)
      : loops.where((l) => l.commitment.direction == directionFilter);

  final buckets = {
    for (final s in DerivedStatus.values) s: <LoopWithPerson>[],
  };
  for (final loop in filtered) {
    final status = deriveStatus(
      now: effectiveNow,
      followUpAt: loop.commitment.followUpAt,
      dueDate: loop.commitment.dueDate,
    );
    buckets[status]!.add(loop);
  }

  return [
    for (final s in DerivedStatus.values)
      if (buckets[s]!.isNotEmpty) LoopGroup(status: s, loops: buckets[s]!),
  ];
}

/// Urgency color mapping (pages/home.md) — light and dark variants.
Color statusColor(BuildContext context, DerivedStatus status) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    DerivedStatus.followUpDue =>
      isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
    DerivedStatus.due =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
    DerivedStatus.upcoming =>
      isDark ? const Color(0xFF2DD4BF) : const Color(0xFF14B8A6),
    DerivedStatus.onTrack =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
  };
}
