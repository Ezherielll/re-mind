import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/presentation/person_screen.dart';

import '../../../support/app_test_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDb();
  });
  tearDown(() => db.close());

  Future<void> pumpPersonScreen(WidgetTester tester, int personId) async {
    await pumpScreen(
      tester,
      db: db,
      home: (_) => PersonScreen(personId: personId),
    );
    // getPerson is a real async future; let it complete outside FakeAsync.
    await settleRealAsync(tester);
  }

  testWidgets('shows header and only that person\'s open loops',
      (tester) async {
    final repository = DriftLoopsRepository(db);
    final budi = await repository.findOrCreatePerson('Budi Santoso');
    await repository.createCommitment(
      title: 'Send revision',
      direction: Direction.outgoing,
      personId: budi.id,
    );
    await repository.createCommitment(
      title: 'For someone else',
      direction: Direction.incoming,
    );

    await pumpPersonScreen(tester, budi.id);

    // Header name + the loop row's person chip.
    expect(find.text('Budi Santoso'), findsNWidgets(2));
    expect(find.text('1 open'), findsOneWidget);
    expect(find.text('Send revision'), findsOneWidget);
    expect(find.text('For someone else'), findsNothing);
    await drainStreams(tester);
  });

  testWidgets('shows empty message when nothing pending', (tester) async {
    final repository = DriftLoopsRepository(db);
    final sari = await repository.findOrCreatePerson('Sari');

    await pumpPersonScreen(tester, sari.id);

    expect(find.text('Sari'), findsOneWidget);
    expect(find.text('Nothing pending with Sari.'), findsOneWidget);
    await drainStreams(tester);
  });
}
