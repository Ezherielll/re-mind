import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/core/domain/derived_status.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/presentation/home_groups.dart';

LoopWithPerson _loop({
  required int id,
  Direction direction = Direction.outgoing,
  DateTime? dueDate,
  DateTime? followUpAt,
}) => LoopWithPerson(
  Commitment(
    id: id,
    title: 'loop $id',
    direction: direction,
    status: CommitmentStatus.open,
    dueDate: dueDate,
    followUpAt: followUpAt,
    createdAt: DateTime(2026, 8, 20),
    updatedAt: DateTime(2026, 8, 20),
    note: null,
    sample: false,
  ),
  null,
);

void main() {
  // Wednesday, 2026-08-26 10:00 local.
  final now = DateTime(2026, 8, 26, 10);

  test('groups appear in precedence order and empty groups are omitted', () {
    final groups = groupOpenLoops([
      _loop(id: 1), // on track
      _loop(id: 2, dueDate: DateTime(2026, 9, 1)), // upcoming
      _loop(id: 3, followUpAt: DateTime(2026, 8, 25)), // follow-up due
      _loop(id: 4, dueDate: DateTime(2026, 8, 26)), // due today
    ], now: now);

    expect(groups.map((g) => g.status).toList(), [
      DerivedStatus.followUpDue,
      DerivedStatus.due,
      DerivedStatus.upcoming,
      DerivedStatus.onTrack,
    ]);
    expect(groups[0].loops.single.commitment.id, 3);
    expect(groups[1].loops.single.commitment.id, 4);
    expect(groups[2].loops.single.commitment.id, 2);
    expect(groups[3].loops.single.commitment.id, 1);
  });

  test('direction filter narrows before grouping', () {
    final groups = groupOpenLoops(
      [
        _loop(id: 1, direction: Direction.outgoing),
        _loop(id: 2, direction: Direction.incoming),
      ],
      directionFilter: Direction.incoming,
      now: now,
    );

    final all = groups.expand((g) => g.loops).toList();
    expect(all, hasLength(1));
    expect(all.single.commitment.id, 2);
  });

  test('filter with no matches yields no groups', () {
    final groups = groupOpenLoops(
      [_loop(id: 1, direction: Direction.outgoing)],
      directionFilter: Direction.incoming,
      now: now,
    );
    expect(groups, isEmpty);
  });
}
