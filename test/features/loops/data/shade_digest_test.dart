import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/core/domain/digest.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/data/shade_actions.dart';

import '../../../support/app_test_harness.dart';

void main() {
  group('composeDigestBody', () {
    test('empty list uses the none template', () {
      expect(
        composeDigestBody(
          totalOpen: 0,
          dueToday: 0,
          noneTemplate: 'All clear',
          hangingTemplate: (c) => '$c things hanging',
          chaseTemplate: (c) => ', $c to chase today',
        ),
        'All clear',
      );
    });

    test('counts with a due-today suffix', () {
      expect(
        composeDigestBody(
          totalOpen: 3,
          dueToday: 1,
          noneTemplate: 'All clear',
          hangingTemplate: (c) => '$c things hanging',
          chaseTemplate: (c) => ', $c to chase today',
        ),
        '3 things hanging, 1 to chase today',
      );
    });

    test('no chase suffix when nothing is due today', () {
      expect(
        composeDigestBody(
          totalOpen: 2,
          dueToday: 0,
          noneTemplate: 'All clear',
          hangingTemplate: (c) => '$c things hanging',
          chaseTemplate: (c) => ', $c to chase today',
        ),
        '2 things hanging',
      );
    });
  });

  group('handleShadeAction', () {
    late AppDatabase db;

    setUp(() => db = createInMemoryDb());
    tearDown(() => db.close());

    Future<Commitment> seed() => DriftLoopsRepository(db).createCommitment(
          title: 'Send revision',
          direction: Direction.outgoing,
          followUpAt: DateTime(2026, 8, 27, 9),
          dueDate: DateTime(2026, 9, 1, 9),
        );

    test('done archives the loop', () async {
      final loop = await seed();
      await handleShadeAction(
        actionId: shadeActionDone,
        loopId: loop.id,
        db: db,
        now: DateTime(2026, 8, 24, 10),
      );
      final r = await db.select(db.commitments).get();
      expect(r.firstWhere((x) => x.id == loop.id).status,
          CommitmentStatus.done);
    });

    test('followed up advances the nudge onto the future due date',
        () async {
      final loop = await seed();
      await handleShadeAction(
        actionId: shadeActionFollowedUp,
        loopId: loop.id,
        db: db,
        now: DateTime(2026, 8, 24, 10),
      );
      final stored =
          await (db.select(db.commitments)..where((c) => c.id.equals(loop.id)))
              .getSingle();
      expect(stored.followUpAt, DateTime(2026, 9, 1, 9));
    });

    test('snooze 1d moves the nudge one day at 09:00', () async {
      final loop = await seed();
      await handleShadeAction(
        actionId: shadeActionSnooze1d,
        loopId: loop.id,
        db: db,
        now: DateTime(2026, 8, 24, 10),
      );
      final stored =
          await (db.select(db.commitments)..where((c) => c.id.equals(loop.id)))
              .getSingle();
      expect(stored.followUpAt, DateTime(2026, 8, 25, 9));
    });
  });
}
