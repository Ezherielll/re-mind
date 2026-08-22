import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';

import '../../../support/app_test_harness.dart';

void main() {
  late AppDatabase db;
  late DriftLoopsRepository repository;

  setUp(() {
    db = createInMemoryDb();
    repository = DriftLoopsRepository(db);
  });
  tearDown(() => db.close());

  testWidgets('home renders groups in derived-status precedence order',
      (tester) async {
    final budi = await repository.findOrCreatePerson('Budi');
    // Follow-up due (incoming).
    await repository.createCommitment(
      title: 'Awaiting assets',
      direction: Direction.incoming,
      personId: budi.id,
      followUpAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    // Due today (outgoing).
    final today = DateTime.now();
    await repository.createCommitment(
      title: 'Send invoice',
      direction: Direction.outgoing,
      personId: budi.id,
      dueDate: DateTime(today.year, today.month, today.day, 9),
    );
    // Upcoming (outgoing).
    await repository.createCommitment(
      title: 'Prepare portfolio',
      direction: Direction.outgoing,
      dueDate: DateTime.now().add(const Duration(days: 10)),
    );
    // On track (incoming, follow-up in the future).
    await repository.createCommitment(
      title: 'Awaiting contract',
      direction: Direction.incoming,
      followUpAt: DateTime.now().add(const Duration(days: 5)),
    );

    await pumpApp(tester, db);

    // All four group headers exist, in precedence order vertically.
    final followUp = tester.getTopLeft(find.text('FOLLOW-UP DUE')).dy;
    final due = tester.getTopLeft(find.text('DUE')).dy;
    final upcoming = tester.getTopLeft(find.text('UPCOMING')).dy;
    final onTrack = tester.getTopLeft(find.text('ON TRACK')).dy;
    expect(followUp, lessThan(due));
    expect(due, lessThan(upcoming));
    expect(upcoming, lessThan(onTrack));

    // Counts shown next to each header.
    expect(find.text('· 1'), findsNWidgets(4));

    // Every loop row is visible somewhere on the (scrollable) list.
    expect(find.text('Awaiting assets'), findsOneWidget);
    expect(find.text('Send invoice'), findsOneWidget);
  });

  testWidgets('Waiting for filter narrows to incoming only', (tester) async {
    await repository.createCommitment(
      title: 'Send invoice',
      direction: Direction.outgoing,
      dueDate: DateTime.now(),
    );
    await repository.createCommitment(
      title: 'Awaiting assets',
      direction: Direction.incoming,
      followUpAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    await pumpApp(tester, db);

    await tester.tap(find.text('Waiting for'));
    await tester.pumpAndSettle();

    expect(find.text('Awaiting assets'), findsOneWidget);
    expect(find.text('Send invoice'), findsNothing);

    // Back to All restores it.
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Send invoice'), findsOneWidget);
  });
}
