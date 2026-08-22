import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/presentation/loop_detail_screen.dart';

import '../../../support/app_test_harness.dart';

void main() {
  late AppDatabase db;
  late DriftLoopsRepository repository;

  setUp(() {
    db = createInMemoryDb();
    repository = DriftLoopsRepository(db);
  });
  tearDown(() => db.close());

  testWidgets('due date row opens picker and persists the picked date', (
    tester,
  ) async {
    final budi = await repository.findOrCreatePerson('Budi');
    final loop = await repository.createCommitment(
      title: 'Send revision',
      direction: Direction.outgoing,
      personId: budi.id,
    );

    await pumpScreen(
      tester,
      db: db,
      home: (_) => LoopDetailScreen(loopId: loop.id),
    );
    await settleRealAsync(tester);

    expect(find.text('Send revision'), findsOneWidget);
    expect(find.text('No due date'), findsOneWidget);

    await tester.tap(find.text('No due date'));
    await tester.pumpAndSettle();

    // Pick day 20 in the calendar, then confirm with OK.
    await tester.tap(find.text('20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last);
    await settleRealAsync(tester);

    final stored = (await repository.getLoop(loop.id))!.commitment;
    expect(stored.dueDate, isNotNull);
    expect(stored.dueDate!.day, 20);

    // Row refreshed out of the empty state; person row shows Budi.
    expect(find.text('No due date'), findsNothing);
    expect(find.text('Budi'), findsOneWidget);
  });

  testWidgets('reminder row opens picker and persists follow-up', (
    tester,
  ) async {
    final loop = await repository.createCommitment(
      title: 'Awaiting data',
      direction: Direction.incoming,
    );

    await pumpScreen(
      tester,
      db: db,
      home: (_) => LoopDetailScreen(loopId: loop.id),
    );
    await settleRealAsync(tester);

    // The Reminds row shows a formatted date (default plan stored at capture
    // time is null here since we inserted directly) — tap it and pick.
    await tester.tap(find.text('—'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last);
    await settleRealAsync(tester);

    final stored = (await repository.getLoop(loop.id))!.commitment;
    expect(stored.followUpAt, isNotNull);
    expect(stored.followUpAt!.day, 15);
    await drainStreams(tester);
  });

  testWidgets('action bar: Followed up advances nudge to due date',
      (tester) async {
    final due = DateTime(
      DateTime.now().add(const Duration(days: 5)).year,
      DateTime.now().add(const Duration(days: 5)).month,
      DateTime.now().add(const Duration(days: 5)).day,
      9,
    );
    final loop = await repository.createCommitment(
      title: 'Send revision',
      direction: Direction.outgoing,
      dueDate: due,
    );

    await pumpScreen(
      tester,
      db: db,
      home: (_) => LoopDetailScreen(loopId: loop.id),
    );
    await settleRealAsync(tester);

    await tester.tap(find.text('Followed up'));
    await settleRealAsync(tester);

    final stored = (await repository.getLoop(loop.id))!.commitment;
    // Current nudge (capture +3d) is before the future due → cycle lands on
    // the due date itself.
    expect(stored.followUpAt, due);
    final events = await db.select(db.loopEvents).get();
    expect(events.map((e) => e.type), contains(LoopEventType.followedUp));
  });

  testWidgets('Done archives the loop and pops back', (tester) async {
    final loop = await repository.createCommitment(
      title: 'Send revision',
      direction: Direction.outgoing,
    );

    await pumpScreen(
      tester,
      db: db,
      home: (_) => LoopDetailScreen(loopId: loop.id),
    );
    await settleRealAsync(tester);

    await tester.tap(find.text('Done'));
    await settleRealAsync(tester);

    final archived = await repository.watchArchivedLoops().first;
    expect(archived.single.commitment.status, CommitmentStatus.done);
  });

  testWidgets('Snooze sheet pushes the nudge one day', (tester) async {
    final loop = await repository.createCommitment(
      title: 'Send revision',
      direction: Direction.outgoing,
    );

    await pumpScreen(
      tester,
      db: db,
      home: (_) => LoopDetailScreen(loopId: loop.id),
    );
    await settleRealAsync(tester);

    await tester.tap(find.text('Snooze'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 day'));
    await settleRealAsync(tester);

    final stored = (await repository.getLoop(loop.id))!.commitment;
    expect(stored.followUpAt, isNotNull);
    expect(stored.followUpAt!.hour, 9);
  });
}
